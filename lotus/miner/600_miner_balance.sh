#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
TS=$(date -d "`date +'%F %H:%M:00'`" +%s)
METRIC=lotus
STEP=600
. /etc/profile
ENDPOINT=`cat /usr/local/open-falcon/agent/config/cfg.json | grep hostname  | awk -F'"' '{print $4}'`
if [ ! $ENDPOINT ]
then
        ENDPOINT=$HOSTNAME
fi
TMP=/tmp/lotus-miner-balance.tmp
lotus-miner info  > $TMP
MINER=`cat $TMP | grep Miner | head -1 | awk '{print $NF}'`
function PRINT_LIST {
	TAG="miner=$MINER,balance=$1"
	VALUE=$2
	n=$3
        LIST[$n]="{\"endpoint\": \"$ENDPOINT\", \"tags\": \"$TAG\", \"timestamp\": $TS, \"metric\": \"$METRIC\", \"value\": $VALUE, \"counterType\": \"GAUGE\", \"step\": $STEP},"
}

IFS=$'\n'
n=0
for i in `cat $TMP | grep FIL`
do
	TAG=`echo $i | awk -F':' '{print $1}' | sed 's/ //g'| sed 's/\t//g'`
	VALUE=`echo $i | awk -F':|FIL' '{print $2}' | sed 's/ //g'`
	PRINT_LIST $TAG $VALUE $n
	n=$(($n+1))
done
rm -rf $TMP
echo ${LIST[*]} | sed -e 's/{/[{/' -e 's/},$/}]/'
