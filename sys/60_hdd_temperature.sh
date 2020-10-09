#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

TS=$(date -d "`date +'%F %H:%M:00'`" +%s)
TAG="1"
METRIC="temperature.hdd"
STEP=60

ENDPOINT=`cat /usr/local/open-falcon/agent/config/cfg.json | grep hostname  | awk -F'"' '{print $4}'`
if [ ! $ENDPOINT ]
then
	ENDPOINT=$HOSTNAME
fi


id=1
for HDD_NAME in `fdisk -l| grep /dev/sd | grep "Disk \/dev\/" | awk -F'/|:' '{print $3}'`
do
	VALUE=`hddtemp /dev/$HDD_NAME 2> /dev/null | awk '{print $NF}' | grep -o "[0-9]\{1,2\}"`
	if [ ! $VALUE ]
	then
		continue
	fi
	TEMP_LIST[$id]=$VALUE
	TAG="hddname=$HDD_NAME"
	LIST[$id]="{\"endpoint\": \"$ENDPOINT\", \"tags\": \"$TAG\", \"timestamp\": $TS, \"metric\": \"$METRIC\", \"value\": $VALUE, \"counterType\": \"GAUGE\", \"step\": $STEP},"
	id=$(($id+1))
done



VALUE=`echo ${TEMP_LIST[*]} | tr ' ' '\n' | sort -n | tail -1`
TAG="temperature=max"
METRIC="temperature.hdd.max"
LIST[0]="{\"endpoint\": \"$ENDPOINT\", \"tags\": \"$TAG\", \"timestamp\": $TS, \"metric\": \"$METRIC\", \"value\": $VALUE, \"counterType\": \"GAUGE\", \"step\": $STEP},"

echo ${LIST[*]} | sed -e 's/{/[{/' -e 's/},$/}]/'
