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

#初回のみ300秒待ち
echo "wait 300s"
sleep 300s

#無限ループ開始
while :
do

#5秒タイムアウトでvmstatコマンドを叩く
timeout -sKILL 5 vmstat
if [ $? != 0 ]; then

# タイムアウトしたら強制リブート
echo b > /proc/sysrq-trigger

else

# 正常終了したらuptimeを書いて、30秒後に再度チェック
echo "System is good response."
uptime >> $LOG_DIR/load_average.log
sleep 30s
fi

#5分間のロードアベレージを出す
LA=`uptime | sed -e 's/.*average: //g' -e 's/,//g' | awk '{print $2}'`
LA_CHECK=`echo "$LA > 5" | bc`
echo "LA is $LA"
echo "LA_CHECK is $LA_CHECK"
if [ $LA_CHECK -eq 1  ]; then

#5分間のロードアベレージが5を超えたら強制リブート
now_time=`date "+%Y%m%d-%H%M%S"`
echo "$now_time Load Average Too high $LA! System will force reboot!!" >> $LOG_DIR/rec_error.log
(echo "$now_time Load Average Too high $LA! System will force reboot!!" | mail -s "$now_time Load Average Too high &LA! System will force reboot!!" $MAIL_ADD)&
echo s > /proc/sysrq-trigger
sleep 5s
echo u > /proc/sysrq-trigger
sleep 5s
echo b > /proc/sysrq-trigger

else

# 正常終了したら30秒後に再度チェック
echo "Load Average is Normal."
sleep 30s
fi


done
