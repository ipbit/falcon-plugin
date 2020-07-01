#!/bin/bash
# 
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

TS=$(date -d "`date +'%F %H:%M:00'`" +%s)
TAG="test=1"
METRIC="ceph.osd.health"
STEP=60

ENDPOINT=`cat /usr/local/open-falcon/agent/config/cfg.json | grep hostname  | awk -F'"' '{print $4}'`
if [ ! $ENDPOINT ]
then
	ENDPOINT=$HOSTNAME
fi

IFS=$'\n'
function ceph_osd_health {
	local i=0
	for line in `ceph osd status | sed -e '1,3d'  -e '$d' -e 's/  / /g' -e 's/|//g'`
	do
		OSD=`echo $line | awk '{print $1}'`
		HOST=`echo $line | awk '{print $2}'`
		STATE=`echo $line | awk '{print $NF}'`
		TAG="host=$HOST,osd=$OSD"
		if [ "$STATE" == "exists,up" ]
		then
			VALUE=1
		else
			VALUE=0
		fi
		LIST[$i]="{\"endpoint\": \"$ENDPOINT\", \"tags\": \"$TAG\", \"timestamp\": $TS, \"metric\": \"$METRIC\", \"value\": $VALUE, \"counterType\": \"GAUGE\", \"step\": $STEP},"
		i=$(($i+1))
	done
	echo ${LIST[*]} | sed -e 's/{/[{/' -e 's/},$/}]/'
}

ceph_osd_health
