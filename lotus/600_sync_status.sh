#!/bin/bash
# -1=daemon down, 1-3=sync err number
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

TS=$(date -d "`date +'%F %H:%M:00'`" +%s)
TAG="type=sync.status"
METRIC=lotus
STEP=600

ENDPOINT=`cat /usr/local/open-falcon/agent/config/cfg.json | grep hostname  | awk -F'"' '{print $4}'`
if [ ! $ENDPOINT ]
then
	ENDPOINT=$HOSTNAME
fi

DAEMON=`su - ipfsbit -c "kubectl get pods -n lotus | grep lotus-daemon | grep Running | awk '{print $1}' 2> /dev/null"`
VALUE=`su - ipfsbit -c "kubectl  -n lotus exec -it $DAEMON -- /home/master/lotus sync status | grep "Stage:" | grep -i err | wc -l 2> /dev/null"`

function PRINT_LIST {
	LIST[0]="{\"endpoint\": \"$ENDPOINT\", \"tags\": \"$TAG\", \"timestamp\": $TS, \"metric\": \"$METRIC\", \"value\": $VALUE, \"counterType\": \"GAUGE\", \"step\": $STEP},"	
	echo ${LIST[*]} | sed -e 's/{/[{/' -e 's/},$/}]/'
}

if [ ! $DAEMON ]
then
	VALUE=-1
fi


PRINT_LIST
