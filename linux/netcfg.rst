Setup multiple profiles
=======================

echo > /etc/network.d/eth0-dhcp << EOF
CONNECTION='ethernet'
DESCRIPTION='A basic dhcp ethernet connection using iproute'
INTERFACE='eth0'
IP='dhcp'
EOF

echo > /etc/network.d/wlan0-MAYA << EOF
CONNECTION='wireless'
DESCRIPTION='Automatically generated profile by wifi-menu'
INTERFACE='wlan0'
SECURITY='wpa'
ESSID=MAYA
IP='dhcp'
KEY=SecretPassword
EOF

sed -i 's/^NETWORKS.*/NETWORKS=(eth0-dhcp,wlan0-MAYA)/' /etc/conf.d/netcfg

Connect on boot
===============

sudo systemctl enable netcfg

Connect on ethernet detection
=============================

sed -i 's/^WIRE_INTERFACE.*/WIRE_INTERFACE="eth0"/' /etc/conf.d/netcfg
sudo pacman -S ifplugd
sudo systemctl enable net-auto-wired