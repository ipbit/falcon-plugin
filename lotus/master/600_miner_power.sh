#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

TS=$(date -d "`date +'%F %H:%M:00'`" +%s)
METRIC=lotus.power
STEP=600
. /etc/profile
ENDPOINT=`cat /usr/local/open-falcon/agent/config/cfg.json | grep hostname  | awk -F'"' '{print $4}'`
if [ ! $ENDPOINT ]
then
        ENDPOINT=$HOSTNAME
fi


LOCK=/tmp/lotus_power_info_falcon.lock
if [ -f $LOCK ]
then
        exit 1
fi
echo 1 > $LOCK

MINER=`lotus-miner info | grep Miner | head -1 | awk '{print $NF}'`
if [ ! $MINER ]
then
        rm -rf $LOCK
        exit 1
fi

TAG="miner=$MINER"
VALUE=`lotus state power $MINER | awk -F'(' '{print $1}'`
LIST="{\"endpoint\": \"$ENDPOINT\", \"tags\": \"$TAG\", \"timestamp\": $TS, \"metric\": \"$METRIC\", \"value\": $VALUE, \"counterType\": \"GAUGE\", \"step\": $STEP},"

rm -rf $LOCK
echo $LIST | sed -e 's/{/[{/' -e 's/},$/}]/'

