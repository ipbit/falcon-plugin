#!/bin/bash
#
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

TS=$(date -d "`date +'%F %H:%M:00'`" +%s)
METRIC="ceph.used.percent"
STEP=300
ENDPOINT=`cat /usr/local/open-falcon/agent/config/cfg.json | grep hostname  | awk -F'"' '{print $4}'`
if [ ! $ENDPOINT ]
then
	ENDPOINT=$HOSTNAME
fi

function value_init {
	i=0
	for POOL in `ceph osd lspools | awk '{print $2}'`
	do
		TAG="fstype=ceph,pool=$POOL"
		VALUE=`ceph df | grep " $POOL " | awk '{print $5}'`
		LIST[$i]="{\"endpoint\": \"$ENDPOINT\", \"tags\": \"$TAG\", \"timestamp\": $TS, \"metric\": \"$METRIC\", \"value\": $VALUE, \"counterType\": \"GAUGE\", \"step\": $STEP},"
		i=$(($i+1))
	done

}


value_init
echo ${LIST[*]} | sed -e 's/{/[{/' -e 's/},$/}]/'