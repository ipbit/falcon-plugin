#!/bin/bash
# 1=ok, 2=warn, 3=err
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

TS=$(date -d "`date +'%F %H:%M:00'`" +%s)
TAG="item=health"
METRIC=ceph
STEP=60

ENDPOINT=`cat /usr/local/open-falcon/agent/config/cfg.json | grep hostname  | awk -F'"' '{print $4}'`
if [ ! $ENDPOINT ]
then
	ENDPOINT=$HOSTNAME
fi


CEPH_VALUE=`ceph -s | grep "health:" | awk -F'[: ]' '{print $NF}' 2> /dev/null`
if [ "$CEPH_VALUE" == "HEALTH_OK" ]
then
    VALUE=1
elif [ "$CEPH_VALUE" == "HEALTH_WARN" ]
then
    VALUE=2
else
	VALUE=3
fi

LIST[0]="{\"endpoint\": \"$ENDPOINT\", \"tags\": \"$TAG\", \"timestamp\": $TS, \"metric\": \"$METRIC\", \"value\": $VALUE, \"counterType\": \"GAUGE\", \"step\": $STEP},"
echo ${LIST[*]} | sed -e 's/{/[{/' -e 's/},$/}]/'