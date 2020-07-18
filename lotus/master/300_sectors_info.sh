#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

TS=$(date -d "`date +'%F %H:%M:00'`" +%s)
METRIC=lotus.sectors
STEP=300

ENDPOINT=`cat /usr/local/open-falcon/agent/config/cfg.json | grep hostname  | awk -F'"' '{print $4}'`
if [ ! $ENDPOINT ]
then
	ENDPOINT=$HOSTNAME
fi

TMP=/tmp/lotus_sectors_info_falcon.tmp
LOCK=/tmp/lotus_sectors_info_falcon.lock

if [ -f $LOCK ]
then
        exit 1
fi

function PRINT_LIST {
	n=$1
	LIST[$n]="{\"endpoint\": \"$ENDPOINT\", \"tags\": \"$TAG\", \"timestamp\": $TS, \"metric\": \"$METRIC\", \"value\": $VALUE, \"counterType\": \"GAUGE\", \"step\": $STEP},"	
	#echo ${LIST[*]} | sed -e 's/{/[{/' -e 's/},$/}]/'
}

echo 1 > $LOCK
#STM=`kubectl get pods -n lotus | grep lotus-storage | grep Running| awk '{print $1}'`
STM=`su - ipfsbit -c "kubectl get pods -n lotus" | grep lotus-storage | grep Running| awk '{print $1}'`
su - ipfsbit -c "kubectl -n lotus exec -it  $STM -- /home/master/lotus-storage-miner info" > $TMP

sed -i "s/ //g" $TMP
sed -i "s/\r//g" $TMP 
i=0
for line in `cat $TMP | grep -A 10 ^"Sectors:"| sed '1d'`
do
	STATUS=`echo $line | awk -F':' '{print $1}'` 
	VALUE=`echo $line | awk -F':' '{print $2}'` 
	TAG="info=$STATUS"
	PRINT_LIST $i
	i=$(($i+1))
done
rm -rf $TMP $LOCK
echo ${LIST[*]} | sed -e 's/{/[{/' -e 's/},$/}]/'
