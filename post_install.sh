#!/usr/bin/env bash

echo -e "\e[1;33m This script will Disable the Enterprise Repo, Add & Enable the No-Subscription Repo, 
Add & Disable Test Repo (repo's can be enabled/disabled via the UI in Repositories) 
and attempt the No-Nag fix. PVE7 ONLY \e[0m"
while true; do
    read -p "Start the PVE7 Post Install Script (y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
sed -i "s/^deb/#deb/g" /etc/apt/sources.list.d/pve-enterprise.list
cat <<EOF > /etc/apt/sources.list
deb http://ftp.debian.org/debian bullseye main contrib
deb http://ftp.debian.org/debian bullseye-updates main contrib
deb http://security.debian.org/debian-security bullseye-security main contrib
deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription
# deb http://download.proxmox.com/debian/pve bullseye pvetest
EOF
echo "DPkg::Post-Invoke { \"dpkg -V proxmox-widget-toolkit | grep -q '/proxmoxlib\.js$'; if [ \$? -eq 1 ]; then { echo 'Removing subscription nag from UI...'; sed -i '/data.status/{s/\!//;s/Active/NoMoreNagging/}' /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js; }; fi\"; };" > /etc/apt/apt.conf.d/no-nag-script
apt --reinstall install proxmox-widget-toolkit &>/dev/null
echo -e "\e[1;33m Finished....Please Update Proxmox \e[0m"

# bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/post_install.sh)"
