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
sleep 30s

#NLL modeが有効な場合はraspividプロセスが動いていないかチェックする

if [ $NLLFLAG -eq 1 ]
  then
  echo "check raspivid process"
  ps aux | grep raspivid | grep -v grep
  if [ "$?" -eq 0 ]
  then
  echo "raspivid is running.skip usb memory move"
  exit 0
  else
  echo "raspivid is not running.continue usb memory move"
fi
fi

#自分自身が動いてたら終了する⇒flockを使うので不要
#if [ $$ != `pgrep -fo $0`  ]; then
#    echo "[`date '+%Y/%m/%d %T'`] This script is already running. exit now."
#    exit 1
#fi

#mp4コンバート中は負荷を考慮し、USBメモリへファイル移動しない
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

#初期判定
echo "USB MEMORY MOVE 1st check"
#dfコマンドで/media/pi/RASPI以下の使用量パーセンテージを書き込む
#DISK_PERを確認する
DISK_PER_USB=`/bin/df /media/pi/RASPI | /usr/bin/tail -1 | /bin/sed 's/^.* \([0-9]*\)%.*$/\1/'`
echo $DISK_PER_USB
  if [ $DISK_PER_USB -gt 99 ]
  then

#99パーセント以上なら通知して終了する
source /opt/ingado-iot-camera/common.conf
echo "$now_time USB MEMORY Full!! Stopped move files to USB MEMORY " >> $LOG_DIR/rec_script.log
(echo -e "$HOSTNAME $now_time USB MEMORY is Full!! Stopped move files to USB MEMORY  $MAILINFO" | mail -s "$HOSTNAME $now_time USB MEMORY Full!! Stopped move files to USB MEMORY " $MAIL_ADD)&
exit 0
    break
  fi

#USBメモリがマウントされていればmvする
echo "USB MEMORY MOVE 2nd check"
if [ -d $USB_MEM_DIR ]; then
source /opt/ingado-iot-camera/common.conf
#(echo -e "$now_time move file to USB Memory started!! $MAILINFO" | mail -s "MOVE FILE to USB $now_time" $MAIL_ADD)&

#nice mv $SCRIPT_DIR/rec/*.mp4 $SCRIPT_DIR/rec/*.h264 $USB_MEM_DIR/
#nice cp -af $SCRIPT_DIR/rec/*.log $USB_MEM_DIR/
nice mv $SCRIPT_DIR/rec/*.mp4 $SCRIPT_DIR/rec/*.h264 $USB_MEM_DIR/
nice cp -af $SCRIPT_DIR/rec/*.log $USB_MEM_DIR/

else
  echo "USB memory is not insert"
  exit 0
fi

#mv処理後判定
echo "USB MEMORY MOVE 3rd check"
#dfコマンドで/media/pi/RASPI以下の使用量パーセンテージを書き込む
#DISK_PERを確認する
DISK_PER_USB=`/bin/df /media/pi/RASPI | /usr/bin/tail -1 | /bin/sed 's/^.* \([0-9]*\)%.*$/\1/'`
echo $DISK_PER_USB

  if [ $DISK_PER_USB -gt 99 ]
  then

#99パーセント以上なら通知して終了する
source /opt/ingado-iot-camera/common.conf
echo "$now_time USB MEMORY Full!! Stopped move files to USB MEMORY " >> $LOG_DIR/rec_script.log
(echo -e "$HOSTNAME $now_time USB MEMORY is Full!! Stopped move files to USB MEMORY $MAILINFO" | mail -s "$HOSTNAME $now_time USB MEMORY Full!! Stopped move files to USB MEMORY " $MAIL_ADD)&
echo "$HOSTNAME $now_time USB MEMORY is Full!! Stopped move files to USB MEMORY" >> $LOG_DIR/rec_script.log

exit 0

#それ以外なら正常にmv終了していると判定し、メール通知
else
source /opt/ingado-iot-camera/common.conf
(echo -e "$HOSTNAME $now_time move file to USB Memory completed!! $MAILINFO" | mail -s "$HOSTNAME MOVE FILE to USB Finished $now_time" $MAIL_ADD)&
echo "$now_time move mp4s completed" >> $LOG_DIR/rec_script.log
echo "$now_time move mp4s completed" >> $USB_MEM_DIR/file_move_date.log

fi

exit 0
