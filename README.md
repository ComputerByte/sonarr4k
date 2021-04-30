# Sonarr 4K Installer
### For Swizzin installs
Second Sonarr Installation on Swizzin based systems

Uses existing install as a base. you must ``sudo box install sonarrv3`` prior to running this script. 

Run install.sh as sudo
```bash
sudo su -
wget "https://raw.githubusercontent.com/ComputerByte/sonarr4k/main/sonarr4kinstall.sh"
chmod +x ~/sonarr4kinstall.sh
~/sonarr4kinstall.sh
```
Sometimes Sonarr1 won't start due to another Sonarr existing, use the panel to stop Sonarr and Sonarr4k, enable Sonarr and wait a second before starting Sonarr4k or

```bash
sudo systemctl stop sonarr && sudo systemctl stop sonarr4k
sudo systemctl start sonarr
sudo systemctl start sonarr4k
```

The log file should be located at ``/root/log/swizzin.log``.

# Uninstaller: 

```bash
sudo su -
wget "https://raw.githubusercontent.com/ComputerByte/sonarr4k/main/sonarr4kuninstall.sh"
chmod +x ~/sonarr4kuninstall.sh
~/sonarr4kuninstall.sh
```

