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

#メール設定を書き込み
echo "hostname=$HOSTNAME" > /etc/ssmtp/ssmtp.conf
echo "AuthUser=$SMTP_USER" >> /etc/ssmtp/ssmtp.conf
echo "AuthPass=$SMTP_PASSWORD" >> /etc/ssmtp/ssmtp.conf
echo "mailhub=$SMTP_SERVER" >> /etc/ssmtp/ssmtp.conf
echo "UseSTARTTLS=YES" >> /etc/ssmtp/ssmtp.conf
echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf

#処理開始
echo "interconnection_check started!!" >> $LOG_DIR/rec_script.log
result=`wget --spider -nv http://www.google.com 2>&1 | grep -c '200 OK'`
if [ ${result} -ne 1 ]; then
echo "interconnection is down. skip time setting"  >> $LOG_DIR/rec_script.log
$SCRIPT_DIR/5_rec_start_unknown_time.sh &
exit 0
else
echo "interconnection is active."  >> $LOG_DIR/rec_script.log
$SCRIPT_DIR/2_time_set.sh &
fi
