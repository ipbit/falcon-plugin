#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

TS=$(date -d "`date +'%F %H:%M:00'`" +%s)

id=1
for HDD_NAME in `fdisk -l| grep /dev/sd | grep "Disk \/dev\/" | awk -F'/|:' '{print $3}'`
do
	HDD_TEMP=`hddtemp /dev/$HDD_NAME | awk '{print $NF}' | grep -o "[0-9]\{1,2\}"`
	TEMP_LIST[$id]=$HDD_TEMP
	LIST[$id]="{\"endpoint\": \"$HOSTNAME\", \"tags\": \"hddname=$HDD_NAME\", \"timestamp\": $TS, \"metric\": \"temperature.hdd\", \"value\": $HDD_TEMP, \"counterType\": \"GAUGE\", \"step\": 60}," 
	id=$(($id+1))
done



MAX_TEMP=`echo ${TEMP_LIST[*]} | tr ' ' '\n' | sort -n | tail -1`
LIST[0]="{\"endpoint\": \"$HOSTNAME\", \"tags\": \"temperature=max\", \"timestamp\": $TS, \"metric\": \"temperature.hdd.max\", \"value\": $MAX_TEMP, \"counterType\": \"GAUGE\", \"step\": 60}," 

echo ${LIST[*]} | sed -e 's/{/[{/' -e 's/},$/}]/'