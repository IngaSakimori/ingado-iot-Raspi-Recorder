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

#スペシャルコマンドを実行したい場合はcommon.confに書く
sudo $SP_COMMAND

#互換性のため、ssmtpとmstp双方へ設定書き出し
  echo "hostname=$HOSTNAME" > /etc/ssmtp/ssmtp.conf
  echo "AuthUser=$SMTP_USER" >> /etc/ssmtp/ssmtp.conf
  echo "AuthPass=$SMTP_PASSWORD" >> /etc/ssmtp/ssmtp.conf
  echo "mailhub=$SMTP_SERVER" >> /etc/ssmtp/ssmtp.conf
  echo "UseSTARTTLS=YES" >> /etc/ssmtp/ssmtp.conf
  echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf
  echo "account default" > /etc/msmtprc
  echo "host smtp.gmail.com" >> /etc/msmtprc
  echo "port 587" >> /etc/msmtprc
  echo "user $SMTP_USER" >> /etc/msmtprc
  echo "password $SMTP_PASSWORD" >> /etc/msmtprc
  echo "from $SMTP_USER" >> /etc/msmtprc
  echo "tls on" >> /etc/msmtprc
  echo "tls_starttls on" >> /etc/msmtprc
  echo "tls_certcheck off" >> /etc/msmtprc
  echo "auth on" >> /etc/msmtprc
  echo "syslog LOG_MAIL" >> /etc/msmtprc

#USBメモリに録画停止ファイルがある場合は、録画を開始せずにエンコードを始める
if [[ -f /media/pi/RASPI/stop_rec ]]; then
  # USBメモリのルートにファイル「stop_rec」がある場合は録画を開始せずにエンコードを始める
  echo "stop_rec file found. Rec will not start." >> $LOG_DIR/rec_script.log
  (echo -e "$HOSTNAME $now_time script and conf update completed!! System will reboot!! $MAILINFO" | mail -s "$HOSTNAME stop_rec file found. Rec will not start!! $now_time" $MAIL_ADD)&
  rm -f /media/pi/RASPI/stop_rec
  touch /media/pi/RASPI/stop_rec_success`date "+%Y%m%d_%H%M"`
  exit 0

fi

#処理開始
echo "$now_time internet connection_check started!!" >> $LOG_DIR/rec_script.log
result=`timeout -sKILL 10 wget --spider -nv http://www.google.com 2>&1 | grep -c '200 OK'`
if [ ${result} -ne 1 ]; then
echo "$now_time internet connection is down. skip time setting"  >> $LOG_DIR/rec_script.log

$SCRIPT_DIR/5_rec_start_unknown_time.sh &
exit 0

else
echo "$now_time internet connection is active."  >> $LOG_DIR/rec_script.log
$SCRIPT_DIR/2_time_set.sh &
fi
exit 0
