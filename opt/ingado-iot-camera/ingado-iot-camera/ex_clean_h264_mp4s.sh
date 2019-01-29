#!/bin/bash
source /opt/ingado-iot-camera/common.conf

echo "録画プロセスを停止して録画ファイルをすべて消します"

read -p "問題なければ何かキーを押す: "

#録画プロセスと録画スクリプトをkillする
sudo $SCRIPT_DIR/9_kill_raspi_rec.sh

#ファイル削除
sudo rm -f $SCRIPT_DIR/rec_convert/* > /dev/null 2>&1
sudo rm -f $SCRIPT_DIR/rec_convert/tmp/* > /dev/null 2>&1
sudo rm -f $SCRIPT_DIR/rec_convert/failed/* > /dev/null 2>&1
sudo rm -f $SCRIPT_DIR/rec_h264/* > /dev/null 2>&1
sudo rm -f $SCRIPT_DIR/rec/* > /dev/null 2>&1

echo "削除完了"

exit 0

