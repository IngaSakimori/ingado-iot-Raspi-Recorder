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

#NLLモードのフラグをチェックし、有効ならばNLLSETを書き込む
if [ $NLLFLAG -eq 1 ]
then
  echo "$now_time $HOSTNAME NLL mode is active. Background convert and USB memory move is stop while recording(raspivid running)" >> $LOG_DIR/rec_script.log
  NLLSET="_NLL_mode"
else
  echo "$now_time $HOSTNAME Normal mode is active." >> $LOG_DIR/rec_script.log
fi


#USBメモリに録画停止ファイルがある場合は、録画を開始せずにエンコードを始める
if [[ -f /media/pi/RASPI/stop_rec ]]; then
  # USBメモリのルートにファイル「stop_rec」がある場合は録画を開始せずにエンコードを始める
  echo "$now_time stop_rec file found. Rec will not start." >> $LOG_DIR/rec_script.log
  (echo -e "$HOSTNAME $now_time stop_rec file found. Rec will not start!! $MAILINFO" | mail -s "$HOSTNAME stop_rec file found. Rec will not start!! $now_time" $MAIL_ADD)&
  rm -f /media/pi/RASPI/stop_rec
  touch /media/pi/RASPI/stop_rec_success`date "+%Y%m%d_%H%M"`
  exit 0

fi

#NLLモードのフラグが有功であり、さらにUSBメモリが刺さっている場合、直接USBメモリへ録画ファイルを録画時間無限で書き出す
if [ $NLLFLAG -eq 1 -a -d /media/pi/RASPI ]
then
  echo "$now_time $HOSTNAME NLL mode is active and USB Memory is detected. Rec file record USB memory directly" >> $LOG_DIR/rec_script.log
  echo "$now_time NLL USB Memory Direct rec started!!" >> $LOG_DIR/rec_script.log
  (echo -e "$HOSTNAME $now_time NLL USB Memory Direct rec started!! $MAILINFO" | mail -s "$HOSTNAME NLL USB Memory Direct REC STARTED $now_time" $MAIL_ADD)&
   raspivid -o $USB_MEM_DIR/rec-start-$now_time$NLLSET.h264 -fps $FPS -w $WIDE -h $HEIGHT $OPTION $ROTATION $BIT_RATE_FLAG $BIT_RATE -t 99999999999999999 -n $RASPIVID_VERBOSE >> $LOG_DIR/rec_script.log 2>&1
fi

#指定マイクロ秒ずつのH264を書き出し。電源ぶつ切りにも対応する。

while :
do

#カメラユニットの認識がダメならメールして終了する
vcgencmd get_camera | grep "detected=1"

if [ ! "$?" -eq 0 ]
then
  source /opt/ingado-iot-camera/common.conf
  echo "$now_time $HOSTNAME camera unit is not detected!! check camera unit and cable!!" >> $LOG_DIR/rec_script.log
  echo "$now_time $HOSTNAME camera unit is not detected!! check camera unit and cable!! $MAILINFO" | mail -s "$HOSTNAME camera unit or cable fail $now_time" $MAIL_ADD
  exit 1
else
  echo 'camera is good status.'
fi

#録画開始。NLLモード有効時はメール通知省略

now_time=`date "+%Y%m%d-%H%M%S"`

if [ $NLLFLAG -eq 1 ]
then
  echo "rec started!!"
else
  echo "$now_time rec started!!" >> $LOG_DIR/rec_script.log
  (echo -e "$HOSTNAME $now_time rec started!! $MAILINFO" | mail -s "$HOSTNAME REC STARTED $now_time" $MAIL_ADD)&
fi

#  nice -n -10 raspivid -o $SCRIPT_DIR/rec_h264/rec-start-$now_time$NLLSET.h264 -fps $FPS -w $WIDE -h $HEIGHT $OPTION $ROTATION $BIT_RATE_FLAG $BIT_RATE -t $REC_TIME $PREVIEW $RASPIVID_VERBOSE  >> $LOG_DIR/rec_script.log 2>&1
  raspivid -o $SCRIPT_DIR/rec_h264/rec-start-$now_time$NLLSET.h264 -fps $FPS -w $WIDE -h $HEIGHT $OPTION $ROTATION $BIT_RATE_FLAG $BIT_RATE -t $REC_TIME $PREVIEW $RASPIVID_VERBOSE  >> $LOG_DIR/rec_script.log 2>&1

#録画したh264は処理フォルダへ移動する
   mv -f $SCRIPT_DIR/rec_h264/rec-start-$now_time$NLLSET.h264 $SCRIPT_DIR/rec_convert

#dfコマンドで/以下の使用量パーセンテージを書き込む
#DISK_PERを確認する
DISK_PER=`/bin/df / | /usr/bin/tail -1 | /bin/sed 's/^.* \([0-9]*\)%.*$/\1/'`

  if [ $DISK_PER -gt $DISK_STOP_PER ]
  then

#容量一杯なら終了する
source /opt/ingado-iot-camera/common.conf
echo "$HOSTNAME $now_time DISK_used over 95 percent! Stopped Rec " >> $LOG_DIR/rec_script.log
echo "$HOSTNAME $now_time DISK_used over 95 percent! Stopped Rec " | mail -s "$HOSTNAME $now_time raspi DISK_PER_Full. Stopped Rec " $MAIL_ADD
    break
  fi

done
