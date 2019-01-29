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

#USBマウントされるディレクトリが既に使われている場合は、いったん中身を移してディレクトリを削除する

if mountpoint -q $USB_MEM_DIR; then
    echo "$USB_MEM_DIR is a mountpoint"
    exit 0
else
    echo "$USB_MEM_DIR is not a mountpoint" 
fi

if [ ! -d $USB_MEM_DIR ]; then
    echo "OK. continue process..."
else
    echo "$now_time USB MOUNT DIR will cleared!!" #>> $LOG_DIR/rec_script.log
    mv -f "$USB_MEM_DIR"/* $SCRIPT_DIR/rec/
    rm -rf "$USB_MEM_DIR"
    echo "$now_time USB MOUNT DIR cleared!! All file move to rec DIR" # >> $LOG_DIR/rec_script.log
    sleep 30s
    reboot
fi

exit 0

