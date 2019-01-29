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

#起動直後に動いた場合を想定し、ちょい待ち
sleep 10s

#自分自身が動いてたら終了する
#if [ $$ != `pgrep -fo $0`  ]; then
#    echo "[`date '+%Y/%m/%d %T'`] This script is already running. exit now."
#    exit 1
#fi

#USBメモリへ移動中は負荷を考慮し、コピーしない
ANOTHER_SCRIPT=`ps aux | grep 10_move_to_usb_memory_mp4s.sh | grep -v grep`
if [[ $ANOTHER_SCRIPT == *"10_move_to_usb_memory_mp4s"* ]]; then
echo "USBメモリへファイル移動中です。しばらく待ってください"
exit 1
fi

#rec_convertディレクトリにあるファイルをtmpへ移す
ls $SCRIPT_DIR/rec_convert/*.h264 >/dev/null 2>&1
if [ $? -ne 0 ]; then
   echo "no convert file!!"
   exit 0
else
   echo "convert file found!!"
   mv $SCRIPT_DIR/rec_convert/*.h264 $SCRIPT_DIR/rec_convert/tmp
fi

for FILE in $SCRIPT_DIR/rec_convert/tmp/*.h264
do
    FILENAME=`echo ${FILE} | sed 's/\.[^\.]*$//'`
#    echo "$now_time ${FILENAME} convert started!!" | mail -s "${FILENAME} CONVERT $now_time" $MAIL_ADD
    ffmpeg -loglevel warning -r $FPS -i ${FILENAME}.h264 -vcodec copy -an -y ${FILENAME}.mp4
    mv ${FILENAME}.mp4 $SCRIPT_DIR/rec
    rm ${FILENAME}.h264
    now_time=`date "+%Y%m%d-%H%M%S"`
    echo "$now_time ${FILENAME}.mp4 convert finished!!" >> $LOG_DIR/rec_script.log
done