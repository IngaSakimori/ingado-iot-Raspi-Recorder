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

#初回のみ60秒待ち
echo "wait 60s"
sleep 60s

#無限ループ開始
while :
do

#15秒タイムアウトでvmstatコマンドを叩く
timeout -sKILL 15 vmstat
if [ $? != 0 ]; then

# タイムアウトしたら強制リブート
echo s > /proc/sysrq-trigger
sleep 5s
echo u > /proc/sysrq-trigger
sleep 5s
echo b > /proc/sysrq-trigger

else

# 正常終了したらuptimeを書いて、60秒後に再度チェック
echo "System is good response."
uptime >> $LOG_DIR/load_average.log
sleep 10s
fi

#DISK_PERを確認する
DISK_PER=`/bin/df / | /usr/bin/tail -1 | /bin/sed 's/^.* \([0-9]*\)%.*$/\1/'`

#使用量パーセンテージを表示する
echo "$DISK_PER"

#使用量が100パーの場合は強制的に録画・コンバート中のファイルを消して、リブートする
if test $DISK_PER -eq 100 ; then
    source /opt/ingado-iot-camera/common.conf
    sudo /opt/ingado-iot-camera/9_kill_raspi_rec.sh &
    sudo rm -f $SCRIPT_DIR/rec_convert/tmp/*.h264
    sudo rm -f $SCRIPT_DIR/rec_convert/tmp/*.mp4
    sudo rm -f $SCRIPT_DIR/rec_convert/*.h264
    echo "$HOSTNAME $now_time DISK_FULL! used 100percent!! delete converting files and reboot" >> $LOG_DIR/rec_script.log
    sleep 120s
    sudo reboot
#使用量が100パーより低ければそのまま
else
    echo "DISK_PERCENTAGE_OK! process continued."
    sleep 10s
fi

#5分間のロードアベレージを出す
LA=`uptime | sed -e 's/.*average: //g' -e 's/,//g' | awk '{print $2}'`
LA_CHECK=`echo "$LA > 5" | bc`
echo "LA is $LA"
echo "LA_CHECK is $LA_CHECK"
if [ $LA_CHECK -eq 1  ]; then

#5分間のロードアベレージが5を超えたら強制リブート
now_time=`date "+%Y%m%d-%H%M%S"`
echo "$HOSTNAME $now_time Load Average Too high $LA! System will force reboot!!" >> $LOG_DIR/rec_script.log
(echo "$HOSTNAME $now_time Load Average Too high $LA! System will force reboot!!" | mail -s "$HOSTNAME $now_time Load Average Too high &LA! System will force reboot!!" $MAIL_ADD)&
echo s > /proc/sysrq-trigger
sleep 5s
echo u > /proc/sysrq-trigger
sleep 5s
echo b > /proc/sysrq-trigger

else

# 正常終了したら60秒後に再度チェック
echo "Load Average is Normal."
sleep 10s
fi

#DISK_PERを確認する
DISK_PER=`/bin/df / | /usr/bin/tail -1 | /bin/sed 's/^.* \([0-9]*\)%.*$/\1/'`

#使用量パーセンテージを表示する
echo "$DISK_PER"

#使用量が95パーより大きい場合は警告し、処理を停止するが、USBメモリへの転送は行う
if test $DISK_PER -gt $DISK_STOP_PER ; then
    source /opt/ingado-iot-camera/common.conf
    echo "$HOSTNAME $now_time DISK_used over 95 percent! process stopped." >> $LOG_DIR/rec_script.log
    /opt/ingado-iot-camera/9_kill_raspi_rec.sh &
    sleep 10s
    flock -e -w 10 /tmp/10_move_to_usb_memory_mp4s.lock $SCRIPT_DIR/10_move_to_usb_memory_mp4s.sh &

#使用量が95パーより低ければそのまま
else
    echo "DISK_PERCENTAGE_OK! process continued."
    sleep 10s
fi

#NLLモードが有効であり、さらに録画プロセスが動いている場合、DISK使用率が85%を超えたらもっとも古いファイルを削除する
#DISK_PERを確認する
DISK_PER=`/bin/df / | /usr/bin/tail -1 | /bin/sed 's/^.* \([0-9]*\)%.*$/\1/'`

#使用量パーセンテージを表示する
echo "$DISK_PER"

#使用量が85パーより大きい場合は録画プロセスをチェックし、動いていたらもっとも古いh264ファイルを削除する

if [ $DISK_PER -gt $DISK_NLL_STOP_PER -a $NLLFLAG -eq 1 ]
then
  echo "check raspivid process"
  ps aux | grep raspivid | grep -v grep
  if [ "$?" -eq 0 ]
  then
  source /opt/ingado-iot-camera/common.conf
  echo "$HOSTNAME $now_time NLL mode is active.raspivid is running. DISK_used over 85 percent! delete oldest H264 file." >> $LOG_DIR/rec_script.log
  echo "oldest H264 file is $OLDEST_H264_FILE" >> $LOG_DIR/rec_script.log
  rm -f $OLDEST_H264_FILE
  echo "oldest H264 files $OLDEST_H264_FILE deleted" >> $LOG_DIR/rec_script.log
  else
  echo "raspivid is not running.skip delete oldest H264 file"
  sleep 10s
fi
fi

#エンドレスモードが有効であり、さらに録画プロセスが動いている場合、DISK使用率が85%を超えたらもっとも古いファイルを削除する
#ただしNLLモードが動いていた場合は無視する。
#DISK_PERを確認する
DISK_PER=`/bin/df / | /usr/bin/tail -1 | /bin/sed 's/^.* \([0-9]*\)%.*$/\1/'`

#使用量パーセンテージを表示する
echo "$DISK_PER"

#使用量が85パーより大きい場合は録画プロセスをチェックし、動いていたらもっとも古いmp4ファイルを削除する

if [ $DISK_PER -gt $DISK_NLL_STOP_PER -a $ENDLESSFLAG -eq 1 -a $NLLFLAG -eq 0 ]
then
  echo "check raspivid process"
  ps aux | grep raspivid | grep -v grep
  if [ "$?" -eq 0 ]
  then
  source /opt/ingado-iot-camera/common.conf
  echo "$HOSTNAME $now_time ENDLESS mode is active.raspivid is running. DISK_used over 85 percent! delete oldest mp4 file." >> $LOG_DIR/rec_script.log
  echo "oldest mp4 file is $OLDEST_MP4_FILE" >> $LOG_DIR/rec_script.log
  rm -f $OLDEST_MP4_FILE
  echo "oldest mp4 files $OLDEST_MP4_FILE deleted" >> $LOG_DIR/rec_script.log
  else
  echo "raspivid is not running.skip delete oldest mp4 file"
fi
fi

done

