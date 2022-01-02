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

source /opt/ingado-iot-camera/common.conf

#Wifiの接続確立とUSBメモリの認識を考慮して少し待機
sleep 40s

logger = "　　　ヘヘヘ　　　　"
logger = "　＜（・∀・）＞　　"
logger = "　　　ＶＶＶ　　　　"
logger = " Piyo-Piyo Fortress "
logger = " Inga-Do Type IoT　 "
logger = " Raspberry Pi Zero Recorder Ver1.2"

#処理開始
echo "$now_time (Unreliable time) Start up process begin!!" >> $LOG_DIR/rec_script.log

#USBメモリに最新のスクリプトやconfがある場合は、上書きする
#wifi設定更新に便利なようにwpa_supplicant.confも更新できるようにする

if [[ -f /media/pi/RASPI/go_update ]]; then
  # USBメモリのルートにファイル「go_update」がある場合はupdateディレクトリのshとconfをmvする
  echo "script and conf update...backup current script and conf" >> $LOG_DIR/rec_script.log
  mkdir $SCRIPT_DIR/update_tmp
  mkdir $SCRIPT_DIR/.script_conf_bak
  cp -a $SCRIPT_DIR/*.sh $SCRIPT_DIR/update_tmp
  cp -a $SCRIPT_DIR/*.conf $SCRIPT_DIR/update_tmp
  sudo cp -a /etc/wpa_supplicant/wpa_supplicant.conf $SCRIPT_DIR/update_tmp
  sudo mv -f /media/pi/RASPI/update/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
  sudo chown root:root /etc/wpa_supplicant/wpa_supplicant.conf
  sudo chmod 644 /etc/wpa_supplicant/wpa_supplicant.conf
  mv $SCRIPT_DIR/update_tmp $SCRIPT_DIR/.script_conf_bak/bak_`date "+%Y%m%d_%H%M"`
  echo "script and conf backup completed!! move new script and conf from USB memory" >> $LOG_DIR/rec_script.log
  mv /media/pi/RASPI/update/*.sh $SCRIPT_DIR
  mv /media/pi/RASPI/update/*.conf $SCRIPT_DIR
  chown pi:pi $SCRIPT_DIR/*.sh
  chown pi:pi $SCRIPT_DIR/*.conf
  chmod 777 $SCRIPT_DIR/*.sh
  chmod 777 $SCRIPT_DIR/*.conf
  echo "script and conf update completed!!" >> $LOG_DIR/rec_script.log
  rm -f /media/pi/RASPI/go_update
  touch /media/pi/RASPI/update_success`date "+%Y%m%d_%H%M"`
  # メールが必ずしも飛ばせるとは限らないが、一応飛ばす
  date --set @$(timeout -sKILL 10 wget -q https://ntp-a1.nict.go.jp/cgi-bin/jst -O - | sed -n 4p | cut -d. -f1)
  echo "hostname=$HOSTNAME" > /etc/ssmtp/ssmtp.conf
  echo "AuthUser=$SMTP_USER" >> /etc/ssmtp/ssmtp.conf
  echo "AuthPass=$SMTP_PASSWORD" >> /etc/ssmtp/ssmtp.conf
  echo "mailhub=$SMTP_SERVER" >> /etc/ssmtp/ssmtp.conf
  echo "UseSTARTTLS=YES" >> /etc/ssmtp/ssmtp.conf
  echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf
  source /opt/ingado-iot-camera/common.conf
  (echo -e "$HOSTNAME $now_time script and conf update completed!! System will reboot!! $MAILINFO" | mail -s "$HOSTNAME script and conf update completed!!  System will reboot!! $now_time" $MAIL_ADD)&
  echo "script and conf update completed!! $now_time system will reboot" >> $LOG_DIR/rec_script.log
#何からの誤った無限ループ時に対処する時間が取れるよう、2分間待ってからリブート
  sleep 120s
  sudo reboot
fi


#NLL modeが有効な場合、ファイルシステムがsyncでマウントされているかチェックして、マウントされていなければfstabを書き換えてリブートする
if [ $NLLFLAG -eq 1 ]
  then
  echo "check fstab"
  grep "\s\/\s*ext4\s*defaults,noatime" /etc/fstab
  if [ "$?" -eq 0 ]
  then
  echo "backup current fstab and change filesystem setting to sync"
  mkdir $SCRIPT_DIR/update_tmp
  mkdir $SCRIPT_DIR/.script_conf_bak
  cp -a /etc/fstab $SCRIPT_DIR/.script_conf_bak/fstab.old.`date "+%Y%m%d_%H%M"`
  sed -i -e '/\s\/\s*ext4\s*defaults,noatime/s/defaults,noatime/sync,auto,dev,exec,nouser,rw,suid/' /etc/fstab
  # メールが必ずしも飛ばせるとは限らないが、一応飛ばす
  date --set @$(timeout -sKILL 10 wget -q https://ntp-a1.nict.go.jp/cgi-bin/jst -O - | sed -n 4p | cut -d. -f1)
  echo "hostname=$HOSTNAME" > /etc/ssmtp/ssmtp.conf
  echo "AuthUser=$SMTP_USER" >> /etc/ssmtp/ssmtp.conf
  echo "AuthPass=$SMTP_PASSWORD" >> /etc/ssmtp/ssmtp.conf
  echo "mailhub=$SMTP_SERVER" >> /etc/ssmtp/ssmtp.conf
  echo "UseSTARTTLS=YES" >> /etc/ssmtp/ssmtp.conf
  echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf
  source /opt/ingado-iot-camera/common.conf
  (echo -e "$HOSTNAME $now_time NLL mode is active!! Change filesystem setting from default(aync) to sync. System will reboot $MAILINFO" | mail -s "$HOSTNAME NLL mode is active!! Change filesystem setting from default(aync) to sync. System will reboot $now_time" $MAIL_ADD)&
  echo "NLL mode is active!! Change filesystem setting from default(aync) to sync. $now_time System will reboot" >> $LOG_DIR/rec_script.log
#何からの誤った無限ループ時に対処する時間が取れるよう、2分間待ってからリブート
  sleep 120s
  sudo reboot
  
  else
  echo "fstab setting check is pass. Filesystem is sync mode." >> $LOG_DIR/rec_script.log
  grep "\s\/\s*ext4\s*" /etc/fstab 
fi
fi

#NLL modeが無効な場合、ファイルシステムがasync/defaultsでマウントされているかチェックして、マウントされていなければfstabを書き換えてリブートする
if [ $NLLFLAG -eq 0 ]
  then
  echo "check fstab"
  grep "\s\/\s*ext4\s*defaults,noatime" /etc/fstab
  if [ "$?" -eq 1 ]
  then
  echo "backup current fstab and change filesystem setting to async"
  mkdir $SCRIPT_DIR/update_tmp
  mkdir $SCRIPT_DIR/.script_conf_bak
  cp -a /etc/fstab $SCRIPT_DIR/.script_conf_bak/fstab.old.`date "+%Y%m%d_%H%M"`
  sed -i -e '/\s\/\s*ext4\s*sync,auto,dev,exec,nouser,rw,suid/s/sync,auto,dev,exec,nouser,rw,suid/defaults,noatime/' /etc/fstab
  # メールが必ずしも飛ばせるとは限らないが、一応飛ばす
  date --set @$(timeout -sKILL 10 wget -q https://ntp-a1.nict.go.jp/cgi-bin/jst -O - | sed -n 4p | cut -d. -f1)
  echo "hostname=$HOSTNAME" > /etc/ssmtp/ssmtp.conf
  echo "AuthUser=$SMTP_USER" >> /etc/ssmtp/ssmtp.conf
  echo "AuthPass=$SMTP_PASSWORD" >> /etc/ssmtp/ssmtp.conf
  echo "mailhub=$SMTP_SERVER" >> /etc/ssmtp/ssmtp.conf
  echo "UseSTARTTLS=YES" >> /etc/ssmtp/ssmtp.conf
  echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf
  source /opt/ingado-iot-camera/common.conf
  (echo -e "$HOSTNAME $now_time NLL mode is not active!! Change filesystem setting from sync to default(aync). System will reboot $MAILINFO" | mail -s "$HOSTNAME NLL mode is not active!! Change filesystem setting from sync to default(aync). System will reboot $now_time" $MAIL_ADD)&
  echo "NLL mode is not active!! Change filesystem setting from sync to default(aync). $now_time System will reboot" >> $LOG_DIR/rec_script.log
#何からの誤った無限ループ時に対処する時間が取れるよう、2分間待ってからリブート
  sleep 120s
  sudo reboot
  
  else
  echo "fstab setting check is pass. Filesystem is async mode" >> $LOG_DIR/rec_script.log
  grep "\s\/\s*ext4\s*" /etc/fstab 
fi
fi


#ログファイルにどのプログラムからも書き込めるようにする（権限が戻ってしまうことがあるので、初期設定で777にする）
chmod 777 $LOG_DIR/rec_script.log
chmod 777 $LOG_DIR/rec_error.log
chmod 777 $LOG_DIR/load_average.log
chown pi:pi $SCRIPT_DIR/*.sh
chown pi:pi $SCRIPT_DIR/*.conf
chmod 777 $SCRIPT_DIR/*.sh
chmod 777 $SCRIPT_DIR/*.conf

#dfコマンドで/以下の使用量パーセンテージを書き込む
#DISK_PERを確認する
DISK_PER=`/bin/df / | /usr/bin/tail -1 | /bin/sed 's/^.* \([0-9]*\)%.*$/\1/'`

#使用量パーセンテージを表示する
echo "$DISK_PER"

#使用量が95パーより大きい場合は警告を送信し、処理を停止するが、USBメモリへの転送は行う
if test $DISK_PER -gt $DISK_STOP_PER ; then
  source /opt/ingado-iot-camera/common.conf
    echo "$HOSTNAME $now_time DISK_FULL! startup process stopped." >> $LOG_DIR/rec_script.log
    echo "$HOSTNAME $now_time DISK_FULL! startup process stopped. $MAILINFO" | mail -s "$HOSTNAME $now_time DISK_FULL!! startup process stopped." $MAIL_ADD
    flock -e -w 10 /tmp/10_move_to_usb_memory_mp4s.lock $SCRIPT_DIR/10_move_to_usb_memory_mp4s.sh &

#使用量が95パーより低ければ後続処理を開始する
else
    echo "$HOSTNAME $now_time DISK_PERCENTAGE check OK! process continued." >> $LOG_DIR/rec_script.log

#USBメモリマウント用のディレクトリがおかしくなっていないかチェック
    $SCRIPT_DIR/11_usb_mount_dir_check.sh

#録画途中に電源切ってブツ切りになったh264ファイルはコンバートディレクトリに移す
    mv -f $SCRIPT_DIR/rec_h264/*.h264 $SCRIPT_DIR/rec_convert

#コンバート中に再起動した場合を考慮して、コンバート中のファイルをコンバートディレクトリへ移す
    mv -f $SCRIPT_DIR/rec_convert/tmp/*.h264 $SCRIPT_DIR/rec_convert

#コンバート途中のMP4ファイルはいったん消す
    rm -f $SCRIPT_DIR/rec_convert/tmp/*.mp4

#コンバート必要なファイルは最初にバックグラウンドでコンバート発動
#USBメモリ転送ジョブは続けて動作する
    flock -e -w 10 /tmp/6_convert_h264_to_mp4.lock $SCRIPT_DIR/6_convert_h264_to_mp4.sh &

#初期スクリプト起動
    $SCRIPT_DIR/1_internet_connection_check.sh &

fi

exit 0
