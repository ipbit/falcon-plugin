#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

TS=$(date -d "`date +'%F %H:%M:00'`" +%s)
Miner="f02417 f040665"
METRIC=lotus.power
STEP=300
. /etc/profile
ENDPOINT=`cat /usr/local/open-falcon/agent/config/cfg.json | grep hostname  | awk -F'"' '{print $4}'`
if [ ! $ENDPOINT ]
then
        ENDPOINT=$HOSTNAME
fi



function PRINT_LIST {
        n=$1
        LIST[$n]="{\"endpoint\": \"$ENDPOINT\", \"tags\": \"$TAG\", \"timestamp\": $TS, \"metric\": \"$METRIC\", \"value\": $VALUE, \"counterType\": \"GAUGE\", \"step\": $STEP},"
}


echo ${LIST[*]} | sed -e 's/{/[{/' -e 's/},$/}]/'



n=0
for MINER in `echo $Miner`
do
        TAG="miner=$MINER"
        VALUE=`lotus state power $MINER | awk -F'(' '{print $1}'`
        n=$(($n+1))
        PRINT_LIST $n
done
echo ${LIST[*]} | sed -e 's/{/[{/' -e 's/},$/}]/'
