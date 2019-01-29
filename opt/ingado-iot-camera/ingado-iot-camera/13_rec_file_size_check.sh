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

if [ ! -e $SCRIPT_DIR/rec_h264/*.h264 ]; then
  echo "録画プロセスが動いていません"
  exit 0
else
  echo "録画プロセスが動いています"
fi

#録画しているのにファイルサイズが0の場合、ケーブル不良の可能性が高いのでチェックする
SIZE=`wc -c $SCRIPT_DIR/rec_h264/*.h264 | awk '{print $1}'`
if [ ! 0 -eq $SIZE ]; then
  echo "file size OK!"
  echo "exit process"
  exit 0
else
  echo "file size 0! check again after 30sec"
fi

sleep 30s

#一度ダメだった場合、30秒後にもう一度チェックして、それでもダメならメール通知して、録画終了する。
SIZE2=`wc -c $SCRIPT_DIR/rec_h264/*.h264 | awk '{print $1}'`
if [ ! 0 -eq $SIZE2 ]; then
  echo "file size OK!"
  echo "exit process"
  exit 0
else
  now_time=`date "+%Y%m%d-%H%M%S"`
  echo "Rec process is not normal! File size 0! check camera cable and camera unit!" >> $LOG_DIR/rec_error.log
  echo "Rec process is not normal! File size 0! check camera cable and camera unit!" | mail -s "camera unit or cable fail $now_time" $MAIL_ADD
  $SCRIPT_DIR/9_kill_raspi_rec.sh
#0バイトファイルは録画失敗ディレクトリへ移しておく
  mv $SCRIPT_DIR/rec_h264/*.h264 $SCRIPT_DIR/rec_convert/failed
fi
