#!/bin/bash

# Script by @ComputerByte 
# For Sonarr 4K Uninstalls

# Log to Swizzin.log
export log=/root/logs/swizzin.log
touch $log

systemctl disable --now -q sonarr4k
rm /etc/systemd/system/sonarr4k.service
systemctl daemon-reload -q

if [[ -f /install/.nginx.lock ]]; then
    rm /etc/nginx/apps/sonarr4k.conf
    systemctl reload nginx
fi

rm /install/.sonarr4k.lock

sed -e "s/class sonarr4k_meta://g" -i /opt/swizzin/core/custom/profiles.py
sed -e "s/    name = \"sonarr4k\"//g" -i /opt/swizzin/core/custom/profiles.py
sed -e "s/    pretty_name = \"Sonarr 4K\"//g" -i /opt/swizzin/core/custom/profiles.py
sed -e "s/    baseurl = \"\/sonarr4k\"//g" -i /opt/swizzin/core/custom/profiles.py
sed -e "s/    systemd = \"sonarr4k\"//g" -i /opt/swizzin/core/custom/profiles.py
sed -e "s/    check_theD = True//g" -i /opt/swizzin/core/custom/profiles.py
sed -e "s/    img = \"sonarr\"//g" -i /opt/swizzin/core/custom/profiles.py
sed -e "s/class sonarr_meta(sonarr_meta)://g" -i /opt/swizzin/core/custom/profiles.py
