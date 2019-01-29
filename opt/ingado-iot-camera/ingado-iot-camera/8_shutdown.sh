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

now_time=`date "+%Y%m%d-%H%M%S"`

#録画を止めてメール通知してシャットダウン
$SCRIPT_DIR/9_kill_raspi_rec.sh
echo "$now_time raspi shutdown!!" | mail -s " $now_time raspi shutdown!! " $MAIL_ADD
shutdown -h now
