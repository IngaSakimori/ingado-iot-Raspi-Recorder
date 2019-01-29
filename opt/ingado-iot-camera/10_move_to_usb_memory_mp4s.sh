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

#コンバート中は負荷を考慮し、USBメモリへファイル移動しない
ANOTHER_SCRIPT=`ps aux | grep 6_convert_h264_to_mp4.sh | grep -v grep`
if [[ $ANOTHER_SCRIPT == *"6_convert_h264_to_mp4"* ]]; then
echo "コンバート中はUSBメモリへファイル移動をしません"
exit 1
fi

#recディレクトリにあるファイルをUSBへ移す
ls $SCRIPT_DIR/rec/*.mp4 >/dev/null 2>&1
if [ $? -ne 0 ]; then
   echo "no mp4 file!!"
   exit 0
else
   echo "mp4 file found. move to USB memory!!"
fi

if [ -d $USB_MEM_DIR ]; then

now_time=`date "+%Y%m%d-%H%M%S"`
#echo "$now_time move file to USB Memory started!!" | mail -s "MOVE FILE to USB $now_time" $MAIL_ADD
mv $SCRIPT_DIR/rec/*.mp4 $USB_MEM_DIR/
now_time=`date "+%Y%m%d-%H%M%S"`
#echo "$now_time move file to USB Memory completed!!" | mail -s "MOVE FILE to USB Finished $now_time" $MAIL_ADD
echo "$now_time move mp4s completed" >> $USB_MEM_DIR/file_move_date.log

else 
  echo "USB memory is not insert"

fi

exit 0
