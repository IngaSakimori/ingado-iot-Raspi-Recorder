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

#録画プロセスと録画スクリプトをkillする

ps aux | grep "4_rec_start_correct_time.sh" | grep -v grep | awk '{ print "kill", $2 }' | sh
ps aux | grep "5_rec_start_unknown_time.sh" | grep -v grep | awk '{ print "kill", $2 }' | sh
ps aux | grep raspistill | grep -v grep | awk '{ print "kill", $2 }' | sh
ps aux | grep raspivid | grep -v grep | awk '{ print "kill", $2 }' | sh

#録画ファイルがあれば、コンバートディレクトリへ移しておく
mv $SCRIPT_DIR/rec_h264/*.h264 $SCRIPT_DIR/rec_convert

exit 0

