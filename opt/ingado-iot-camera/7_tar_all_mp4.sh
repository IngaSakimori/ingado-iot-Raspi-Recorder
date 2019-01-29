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

echo "tar all mp4!!"

echo "コンバートディレクトリ等にファイルが残っていないかチェックします"

echo "ls -l $SCRIPT_DIR/rec_convert"
ls -l $SCRIPT_DIR/rec_convert

echo "$SCRIPT_DIR/rec_convert/tmp"
ls -l $SCRIPT_DIR/rec_convert/tmp

echo "$SCRIPT_DIR/rec_h264"
ls -l $SCRIPT_DIR/rec_h264

echo "これから以下のファイルを圧縮します"

ls -l $SCRIPT_DIR/rec

read -p "問題なければ何かキーを押す: "

echo "固めます"

now_time=`date "+%Y%m%d-%H%M%S"`
tar cvf $now_time.tar rec/*

echo "固めたファイルは $SCRIPT_DIR/$now_time.tar です"
