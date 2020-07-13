#!/bin/bash
#  0=dead,	1=workers panic
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

TS=$(date -d "`date +'%F %H:%M:00'`" +%s)
TAG="type=workerslist.panic"
METRIC=lotus
STEP=600
TMP=/tmp/lotus_workers_list_panic.tmp
ENDPOINT=`cat /usr/local/open-falcon/agent/config/cfg.json | grep hostname  | awk -F'"' '{print $4}'`
if [ ! $ENDPOINT ]
then
	ENDPOINT=$HOSTNAME
fi


function PRINT_LIST {
	LIST[0]="{\"endpoint\": \"$ENDPOINT\", \"tags\": \"$TAG\", \"timestamp\": $TS, \"metric\": \"$METRIC\", \"value\": $VALUE, \"counterType\": \"GAUGE\", \"step\": $STEP},"	
	echo ${LIST[*]} | sed -e 's/{/[{/' -e 's/},$/}]/'
	rm -rf $LOCK 2> /dev/null
	rm -rf $TMP 2> /dev/null
}

LOCK=/tmp/lotus_workers_list_panic.lock
if [ -e $LOCK ]
then
	VALUE=0
	PRINT_LIST
	exit 1
fi

STM=`su - ipfsbit -c "kubectl get pods -n lotus" | grep lotus-storage | grep Running| awk '{print $1}'`
if [ ! $STM ]
then
	VALUE=0
	PRINT_LIST
	exit 1
fi

echo 1 > $LOCK
su - ipfsbit -c "kubectl exec -it $STM -n lotus -- /home/master/lotus-storage-miner workers list >  $TMP 2> /dev/null"
PANIC=`cat $TMP | grep panic | wc -l`
if [ $PANIC -ge 1 ]
then
	VALUE=1
	PRINT_LIST
	exit 0
fi