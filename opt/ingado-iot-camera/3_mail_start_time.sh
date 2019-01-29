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

echo "Start up complete! $now_time" | mail -s "Start up complete! $now_time" $MAIL_ADD 

$SCRIPT_DIR/4_rec_start_correct_time.sh &
exit 0
