#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

TS=$(date -d "`date +'%F %H:%M:00'`" +%s)
TAG="type=worker.status"
METRIC=lotus
STEP=300
. /etc/profile
ENDPOINT=`cat /usr/local/open-falcon/agent/config/cfg.json | grep hostname  | awk -F'"' '{print $4}'`
if [ ! $ENDPOINT ]
then
        ENDPOINT=$HOSTNAME
fi

function PRINT_LIST {
		PS=`ps aux | grep "lotus-worker" | grep run | grep -v grep | wc -l`
		LISTEN=`netstat -anputl | grep 3456 | grep LISTEN | wc -l`
        if [ $PS -ge 1 ] || [ $LISTEN -eq 1 ]
		then
			VALUE=$PS
		else
			unset VALUE
		fi
        LIST[0]="{\"endpoint\": \"$ENDPOINT\", \"tags\": \"$TAG\", \"timestamp\": $TS, \"metric\": \"$METRIC\", \"value\": $VALUE, \"counterType\": \"GAUGE\", \"step\": $STEP},"
        echo ${LIST[*]} | sed -e 's/{/[{/' -e 's/},$/}]/'
}

PRINT_LIST
