#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

TS=$(date -d "`date +'%F %H:%M:00'`" +%s)
TAG="type=sectors.status"
METRIC=lotus.sectors
STEP=60

ENDPOINT=`cat /usr/local/open-falcon/agent/config/cfg.json | grep hostname  | awk -F'"' '{print $4}'`
if [ ! $ENDPOINT ]
then
	ENDPOINT=$HOSTNAME
fi
if [ ! -d /pool/filecoin ]
then
	exit 0
fi

function PRINT_LIST {
	n=$1
	LIST[$n]="{\"endpoint\": \"$ENDPOINT\", \"tags\": \"$TAG\", \"timestamp\": $TS, \"metric\": \"$METRIC\", \"value\": $VALUE, \"counterType\": \"GAUGE\", \"step\": $STEP},"	
	#echo ${LIST[*]} | sed -e 's/{/[{/' -e 's/},$/}]/'
}

i=1
for SEALED in `ls /pool/filecoin/lotus-work*/sealed | grep ^"s\-"`
do
	VALUE=1
	TAG="type=sealed,sectors=$SEALED"
	PRINT_LIST $i
	i=$(($i+1))
done

for CACHE in `ls /pool/filecoin/lotus-work*/cache | grep ^"s\-"`
do
	VALUE=`ls /pool/filecoin/lotus-work*/cache/$CACHE | grep -v aux | wc -l`
	TAG="type=cache,sectors=$CACHE"
	PRINT_LIST $i
	i=$(($i+1))
done
echo ${LIST[*]} | sed -e 's/{/[{/' -e 's/},$/}]/'
