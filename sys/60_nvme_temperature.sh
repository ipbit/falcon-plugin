#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

TS=$(date -d "`date +'%F %H:%M:00'`" +%s)
TAG="test=1"
METRIC="temperature.nvme"
STEP=60

ENDPOINT=`cat /usr/local/open-falcon/agent/config/cfg.json | grep hostname  | awk -F'"' '{print $4}'`
if [ ! $ENDPOINT ]
then
	ENDPOINT=$HOSTNAME
fi

fdisk -l | grep nvme > /dev/null || exit 1

which nvme > /dev/null || apt install nvme-cli -y > /dev/null 2>&1
 
id=1
for NVME_NAME in `fdisk -l| grep /dev/nvme | grep "Disk \/dev\/" | awk -F'/|:' '{print $3}'`
do
	VALUE=`nvme smart-log /dev/$NVME_NAME | grep -e ^"Temperature Sensor" -e ^"temperature"  | awk '{print $(NF-1)}' | sort -n | tail -1`
	TEMP_LIST[$id]=$VALUE
	TAG="hddname=$NVME_NAME"
	LIST[$id]="{\"endpoint\": \"$ENDPOINT\", \"tags\": \"$TAG\", \"timestamp\": $TS, \"metric\": \"$METRIC\", \"value\": $VALUE, \"counterType\": \"GAUGE\", \"step\": $STEP},"
	id=$(($id+1))
done



VALUE=`echo ${TEMP_LIST[*]} | tr ' ' '\n' | sort -n | tail -1`
TAG="temperature=max"
METRIC="temperature.nvme.max"
LIST[0]="{\"endpoint\": \"$ENDPOINT\", \"tags\": \"$TAG\", \"timestamp\": $TS, \"metric\": \"$METRIC\", \"value\": $VALUE, \"counterType\": \"GAUGE\", \"step\": $STEP},"

echo ${LIST[*]} | sed -e 's/{/[{/' -e 's/},$/}]/'