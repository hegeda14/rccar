source-directory /etc/network/interfaces.d
auto lo
iface lo inet loopback
iface eth0 inet manual
auto eth0
iface eth0 inet static
   address 192.168.20.40
   netmask 255.255.255.0
   network 192.168.20.1
   gateway 192.168.1.1
   dns-nameservers 8.8.8.8 8.8.4.4
allow-hotplug wlan0
iface wlan0 inet manual
   wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
allow-hotplug wlan1
iface wlan1 inet manual
   wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
