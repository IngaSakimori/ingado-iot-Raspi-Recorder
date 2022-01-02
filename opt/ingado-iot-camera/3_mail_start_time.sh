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
(echo -e "$HOSTNAME Start up complete! $now_time $MAILINFO" | mail -s "$HOSTNAME Start up complete! $now_time" $MAIL_ADD)&

$SCRIPT_DIR/4_rec_start_correct_time.sh &
exit 0
