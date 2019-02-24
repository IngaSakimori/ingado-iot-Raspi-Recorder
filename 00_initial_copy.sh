#!/bin/bash
#####################
#  Inga-Do Type IoT #
#####################

######################
#　　　ヘヘヘ　　　　#
#　＜（・∀・）＞　　#
#　　　ＶＶＶ　　　　#
# Piyo-Piyo Fortress #
######################

echo "　　　ヘヘヘ　　　　"
echo "　＜（・∀・）＞　　"
echo "　　　ＶＶＶ　　　　"
echo " Piyo-Piyo Fortress "
echo "copylight 2019 Inga-do Type IoT/IngaSakimori All Rights Reserved"

echo "Please enable CAMERA,SSH,VNC from raspi-config"

sleep 1s

echo "initial update"

apt update

echo "install some packages"

apt install vim-gtk ssmtp mailutils mpack bc lxshortcut xrdp -y

echo "install sysstat. wait few minutes. select Yes"

apt install sysstat -y

echo "enable xrdp. you can access RDP"

systemctl enable xrdp

echo "set clipboard=unnamedplus" >> ~/.vimrc

echo "exec initial copy"

mkdir -p /opt/ingado-iot-camera/rec
mkdir -p /opt/ingado-iot-camera/rec_convert
mkdir -p /opt/ingado-iot-camera/rec_h264
mkdir -p /opt/ingado-iot-camera/rec_convert/tmp
chown -R pi:pi opt/ingado-iot-camera
chmod -R 777 opt/ingado-iot-camera
mv -fv opt/ingado-iot-camera/*.sh /opt/ingado-iot-camera
mv -fv opt/ingado-iot-camera/*.conf /opt/ingado-iot-camera

chmod 755 boot/config.txt
chown root:root boot/config.txt
mv -fv boot/config.txt /boot/config.txt

chmod 600 var/spool/cron/crontabs/root
chown root:crontab var/spool/cron/crontabs/root
mv -fv var/spool/cron/crontabs/root /var/spool/cron/crontabs/root

chmod 644 etc/crontab
chmod 644 etc/sysctl.conf
chown root:root etc/crontab
chown root:root etc/sysctl.conf
mv -fv etc/crontab /etc/crontab
mv -fv etc/sysctl.conf /etc/sysctl.conf

chmod 644 etc/cron.d/sysstat
chmod 644 etc/default/sysstat
chmod 644 etc/logrotate.d/rsyslog
chmod 644 etc/modprobe.d/bcm2835-wdt.conf
chmod 644 etc/ssmtp/ssmtp.conf
chmod 644 etc/systemd/system.conf
chmod 644 etc/wpa_supplicant/wpa_supplicant.conf

chown root:root etc/cron.d/sysstat
chown root:root etc/default/sysstat
chown root:root etc/logrotate.d/rsyslog
chown root:root etc/modprobe.d/bcm2835-wdt.conf
chown root:root etc/ssmtp/ssmtp.conf
chown root:root etc/systemd/system.conf
chown root:root etc/wpa_supplicant/wpa_supplicant.conf

mv -fv etc/cron.d/sysstat /etc/cron.d/sysstat
mv -fv etc/default/sysstat /etc/default/sysstat
mv -fv etc/logrotate.d/rsyslog /etc/logrotate.d/rsyslog
mv -fv etc/modprobe.d/bcm2835-wdt.conf /etc/modprobe.d/bcm2835-wdt.conf
mv -fv etc/ssmtp/ssmtp.conf /etc/ssmtp/ssmtp.conf
mv -fv etc/systemd/system.conf /etc/systemd/system.conf
mv -fv etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf

chmod 644 home/pi/Desktop/MoveToUSB_Memory
chmod 644 home/pi/Desktop/RecStop
chmod 644 home/pi/Desktop/SettingEdit

chown pi:pi home/pi/Desktop/MoveToUSB_Memory
chown pi:pi home/pi/Desktop/RecStop
chown pi:pi home/pi/Desktop/SettingEdit

mv -fv home/pi/Desktop/MoveToUSB_Memory /home/pi/Desktop/MoveToUSB_Memory
mv -fv home/pi/Desktop/RecStop /home/pi/Desktop/RecStop
mv -fv home/pi/Desktop/SettingEdit /home/pi/Desktop/SettingEdit

chmod 644 usr/share/rpd-wallpaper/ingado-iot.jpg
chown root:root usr/share/rpd-wallpaper/ingado-iot.jpg
mv -fv usr/share/rpd-wallpaper/ingado-iot.jpg /usr/share/rpd-wallpaper/ingado-iot.jpg

mkdir -p /home/pi/.config/pcmanfm/LXDE-pi/
chown -R pi:pi /home/pi/.config/pcmanfm/LXDE-pi/
chmod 644 home/pi/.config/pcmanfm/LXDE-pi/desktop-items-0.conf
chown pi:pi home/pi/.config/pcmanfm/LXDE-pi/desktop-items-0.conf
mv -fv home/pi/.config/pcmanfm/LXDE-pi/desktop-items-0.conf /home/pi/.config/pcmanfm/LXDE-pi/desktop-items-0.conf

chmod 777 var/log/rec_error.log
chmod 777 var/log/rec_script.log
chown pi:pi var/log/rec_script.log
chown pi:pi var/log/rec_script.log
mv -fv var/log/rec_error.log /var/log/rec_error.log
mv -fv var/log/rec_script.log /var/log/rec_script.log

echo "initial copy done!!"
echo "Next...run"
echo "command - sudo raspi-config"
echo "select 7 Advanced Options"
echo "select A1 Expand Filesystem"
echo "System Reboot"
echo "Rec process will auto start"

