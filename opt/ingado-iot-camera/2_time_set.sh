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

date --set @$(timeout -sKILL 10 wget -q https://ntp-a1.nict.go.jp/cgi-bin/jst -O - | sed -n 4p | cut -d. -f1)

now_time=`date "+%Y%m%d-%H%M%S"`

echo "$now_time time set completed!!" >> $LOG_DIR/rec_script.log

$SCRIPT_DIR/3_mail_start_time.sh &
exit 0
