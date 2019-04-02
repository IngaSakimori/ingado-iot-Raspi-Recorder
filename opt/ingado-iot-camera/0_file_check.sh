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

logger = "　　　ヘヘヘ　　　　"
logger = "　＜（・∀・）＞　　"
logger = "　　　ＶＶＶ　　　　"
logger = " Piyo-Piyo Fortress "
logger = " Inga-Do Type IoT　 "
logger = " Raspberry Pi Zero Recorder "

#Wifiの接続確立を考慮して少し待機
sleep 20s

#処理開始
echo "Start up process started!!" >> $LOG_DIR/rec_script.log

#dfコマンドで/以下の使用量パーセンテージを書き込む
/bin/df / | /usr/bin/tail -1 | /bin/sed 's/^.* \([0-9]*\)%.*$/\1/' > $SCRIPT_DIR/disk_use_per.txt

#使用量パーセンテージを表示する
DISK_PER=$(<$SCRIPT_DIR/disk_use_per.txt)
echo "$DISK_PER"

#使用量が95パーより大きい場合は警告を送信し、処理を停止するが、USBメモリへの転送は行う
if test $DISK_PER -gt $DISK_STOP_PER ; then
    echo "DISK_FULL! startup process stopped." >> $LOG_DIR/rec_script.log
    echo "DISK_FULL! startup process stopped." | mail -s "DISK_FULL!! startup process stopped." $MAIL_ADD
    flock -e /tmp/10_move_to_usb_memory_mp4s.lock $SCRIPT_DIR/10_move_to_usb_memory_mp4s.sh &

#使用量が95パーより低ければ後続処理を開始する
else
    echo "DISK_PERCENTAGE_OK! process continued." >> $LOG_DIR/rec_script.log

#USBメモリマウント用のディレクトリがおかしくなっていないかチェック
    $SCRIPT_DIR/11_usb_mount_dir_check.sh

#録画途中に電源切ってブツ切りになったh264ファイルはコンバートディレクトリに移す
    mv -f $SCRIPT_DIR/rec_h264/*.h264 $SCRIPT_DIR/rec_convert

#コンバート中に再起動した場合を考慮して、コンバート中のファイルをコンバートディレクトリへ移す
    mv -f $SCRIPT_DIR/rec_convert/tmp/*.h264 $SCRIPT_DIR/rec_convert

#コンバート途中のMP4ファイルはいったん消す
    rm -f $SCRIPT_DIR/rec_convert/tmp/*.mp4

#コンバート必要なファイルは最初にコンバートする
    flock -e /tmp/6_convert_h264_to_mp4.lock $SCRIPT_DIR/6_convert_h264_to_mp4.sh &

#USBメモリが刺さっていれば最初にバックグラウンドで移動させる
    flock -e /tmp/10_move_to_usb_memory_mp4s.lock $SCRIPT_DIR/10_move_to_usb_memory_mp4s.sh &

#初期スクリプト起動
    $SCRIPT_DIR/1_interconnection_check.sh &

fi
