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

echo "date is unknown!!" >> $LOG_DIR/rec_script.log

#指定マイクロ秒ずつのH264を書き出し。電源ぶつ切りにも対応する。

while :
do

#カメラユニットの認識がダメならログして終了する
vcgencmd get_camera | grep "detected=1"

if [ ! "$?" -eq 0 ]
then
  echo "camera unit is not detected!! check camera unit and cable!!" >> $LOG_DIR/rec_script.log
  exit 1
else
  echo 'camera is good status.'
fi

  now_time=`date "+%Y%m%d-%H%M%S"`
  echo "Date is not correct. fake time $now_time rec started!!" >> $LOG_DIR/rec_script.log
  raspivid -o $SCRIPT_DIR/rec_h264/rec-start-fake-time-$now_time.h264 -fps $FPS -w $WIDE -h $HEIGHT -b $BIT_RATE -t $REC_TIME $PREVIEW
#録画したh264は処理フォルダへ移動する
  mv $SCRIPT_DIR/rec_h264/rec-start-fake-time-$now_time.h264 $SCRIPT_DIR/rec_convert

  #dfコマンドで/以下の使用量パーセンテージを書き込む
/bin/df / | /usr/bin/tail -1 | /bin/sed 's/^.* \([0-9]*\)%.*$/\1/' > $SCRIPT_DIR/disk_use_per.txt

disk_zan=`cat $SCRIPT_DIR/disk_use_per.txt`

  if [ $disk_zan -gt $DISK_STOP_PER ]
  then

#容量一杯なら終了する
now_time=`date "+%Y%m%d-%H%M%S"`
echo "$now_time raspi DISK_PER_Full. Stopped Rec " >> $LOG_DIR/rec_script.log
    break
  fi

done
