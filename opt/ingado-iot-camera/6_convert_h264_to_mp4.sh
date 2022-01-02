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
  echo "raspivid is running.skip encode"
  exit 0
  else
  echo "raspivid is not running.continue encode"
fi
fi

#自分自身が動いてたら終了する
#if [ $$ != `pgrep -fo $0`  ]; then
#    echo "[`date '+%Y/%m/%d %T'`] This script is already running. exit now."
#    exit 1
#fi

#残り容量が少ない場合はコンバートしない
DISK_PER=`/bin/df / | /usr/bin/tail -1 | /bin/sed 's/^.* \([0-9]*\)%.*$/\1/'`
echo "$DISK_PER"

#使用量が95パーより大きい場合は警告を送信し、処理を停止するが、USBメモリへの転送は行う
if test $DISK_PER -gt $DISK_STOP_PER ; then
    source /opt/ingado-iot-camera/common.conf
    echo "$now_time DISK_FULL! convert process stopped." >> $LOG_DIR/rec_script.log
    (echo -e "$now_time DISK_FULL! convert process stopped. $MAILINFO" | mail -s "$HOSTNAME DISK_FULL!! convert process stopped." $MAIL_ADD)&
    flock -e -w 10 /tmp/10_move_to_usb_memory_mp4s.lock $SCRIPT_DIR/10_move_to_usb_memory_mp4s.sh &
    exit 0
#使用量が95パーより低ければ後続処理を開始する
else
   echo "contiune..."

fi

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
#    echo "$now_time ${FILENAME} convert started!!" | mail -s "$HOSTNAME ${FILENAME} CONVERT $now_time" $MAIL_ADD

     nice ffmpeg -loglevel warning -r $FPS -i ${FILENAME}.h264 -vcodec copy -an -y ${FILENAME}.mp4  >> $LOG_DIR/rec_script.log 2>&1
#    ffmpeg -loglevel warning -r $FPS -i ${FILENAME}.h264 -vcodec copy -an -y ${FILENAME}.mp4  >> $LOG_DIR/rec_script.log 2>&1
#    ffmpeg -loglevel warning -r $FPS -i ${FILENAME}.h264 -vcodec copy -an -y ${FILENAME}.mp4
#    nice ffmpeg -loglevel warning -r $FPS -i ${FILENAME}.h264 -vcodec copy -an -y ${FILENAME}.mp4

    echo "converted ${FILENAME}.mp4...File Check"
    echo "converted ${FILENAME}.mp4...File Check" >> $LOG_DIR/rec_script.log

#mp4のチェックし、ダメージを受けていたら、元のH264ファイルもmvで保全しておく
    nice ffprobe ${FILENAME}.mp4  >> $LOG_DIR/rec_script.log 2>&1
    tail -5 $LOG_DIR/rec_script.log | grep -a "Invalid data found" | grep -a "${FILENAME}.mp4"
    if [ "$?" -eq 1 ]
    then
    echo 'convert OK'
    echo "Invalid data check is pass" >> $LOG_DIR/rec_script.log
    echo "Invalid data check is pass" 
    mv ${FILENAME}.mp4 $SCRIPT_DIR/rec
    rm ${FILENAME}.h264    
    else
    echo 'convert fail!'
    echo "Invalid data check is not pass (damaged file found. save H264 source too)" >> $LOG_DIR/rec_script.log
    echo "Invalid data check is not pass (damaged file found. save H264 source too)"     
    mv ${FILENAME}.mp4 $SCRIPT_DIR/rec
    mv ${FILENAME}.h264 $SCRIPT_DIR/rec
    echo "$now_time damaged file ${FILENAME}.mp4 found, both mp4 and H264 files saved" >> $LOG_DIR/rec_script.log
    echo "$now_time damaged file ${FILENAME}.mp4 found, both mp4 and H264 files saved" >> $SCRIPT_DIR/rec/damaged_file_info.log
    fi

#後処理を実施
    source /opt/ingado-iot-camera/common.conf
    echo "$now_time ${FILENAME}.mp4 convert finished!!" >> $LOG_DIR/rec_script.log
    (echo -e "$now_time ${FILENAME}.mp4 convert finished!! \nNotice, if damaged mp4 file found, both mp4 and H264 files saved rec directory. $MAILINFO" | mail -s "$HOSTNAME ${FILENAME}.mp4 convert finished!! $now_time" $MAIL_ADD)&
done

#続けてUSBメモリ転送ジョブを呼び出す
    flock -e -w 30 /tmp/10_move_to_usb_memory_mp4s.lock $SCRIPT_DIR/10_move_to_usb_memory_mp4s.sh &
    
    exit 0
