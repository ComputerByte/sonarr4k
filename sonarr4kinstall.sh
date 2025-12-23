#!/bin/bash
. /etc/swizzin/sources/globals.sh
. /etc/swizzin/sources/functions/utils

# Script by @ComputerByte
# For Sonarr 4K Installs
#shellcheck=SC1017

# Log to Swizzin.log
export log=/root/logs/swizzin.log
touch $log
# Set variables
user=$(_get_master_username)

echo_progress_start "Making data directory and owning it to ${user}"
mkdir -p "/home/$user/.config/sonarr4k"
chown -R "$user":"$user" /home/$user/.config/sonarr4k
echo_progress_done "Data Directory created and owned."

echo_progress_start "Installing systemd service file"
cat >/etc/systemd/system/sonarr4k.service <<-SERV
# This file is owned by the sonarr package, DO NOT MODIFY MANUALLY
# Instead use 'dpkg-reconfigure -plow sonarr' to modify User/Group/UMask/-data
# Or use systemd built-in override functionality using 'systemctl edit sonarr'
[Unit]
Description=Sonarr Daemon
After=network.target

[Service]
User=${user}
Group=${user}
UMask=0002

Type=simple
ExecStart=/opt/Sonarr/Sonarr -nobrowser -data=/home/${user}/.config/sonarr4k
TimeoutStopSec=20
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
SERV
echo_progress_done "Sonarr 4K service installed"

# This checks if nginx is installed, if it is, then it will install nginx config for sonarr4k
if [[ -f /install/.nginx.lock ]]; then
    echo_progress_start "Installing nginx config"
    cat >/etc/nginx/apps/sonarr4k.conf <<-NGX
location ^~ /sonarr4k {
    proxy_pass http://127.0.0.1:8882;
    proxy_set_header Host \$proxy_host;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Host \$host;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_redirect off;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection \$http_connection;
    auth_basic "What's the password?";
    auth_basic_user_file /etc/htpasswd.d/htpasswd.${user};
}
# Allow the API External Access via NGINX
location ^~ /sonarr4k/api {
    auth_basic off;
    proxy_pass http://127.0.0.1:8882;
}
NGX
    # Reload nginx
    systemctl reload nginx
    echo_progress_done "Nginx config applied"
fi

echo_progress_start "Generating configuration"

# Start sonarr to config
systemctl stop sonarr.service >>$log 2>&1

cat > /home/${user}/.config/sonarr4k/config.xml << EOSC
<Config>
  <LogLevel>info</LogLevel>
  <UpdateMechanism>BuiltIn</UpdateMechanism>
  <Branch>main</Branch>
  <BindAddress>127.0.0.1</BindAddress>
  <Port>8882</Port>
  <SslPort>9898</SslPort>
  <EnableSsl>False</EnableSsl>
  <LaunchBrowser>False</LaunchBrowser>
  <AuthenticationMethod>None</AuthenticationMethod>
  <UrlBase>sonarr4k</UrlBase>
  <UpdateAutomatically>False</UpdateAutomatically>
</Config>
EOSC

chown -R ${user}:${user} \/home/${user}/.config/sonarr4k/
systemctl enable --now sonarr.service >>$log 2>&1
sleep 10
systemctl enable --now sonarr4k.service >>$log 2>&1

echo_progress_start "Patching panel."
systemctl start sonarr4k.service >>$log 2>&1
#Install Swizzin Panel Profiles
if [[ -f /install/.panel.lock ]]; then
    cat <<EOF >>/opt/swizzin/core/custom/profiles.py
class sonarr4k_meta:
    name = "sonarr4k"
    pretty_name = "Sonarr 4K"
    baseurl = "/sonarr4k"
    systemd = "sonarr4k"
    check_theD = False
    img = "sonarr"
class sonarr_meta(sonarr_meta):
    systemd = "sonarr"
    check_theD = False
EOF
fi
touch /install/.sonarr4k.lock >>$log 2>&1
echo_progress_done "Panel patched."
systemctl restart panel >>$log 2>&1
echo_progress_done "Done."
