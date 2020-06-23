#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

TS=$(date -d "`date +'%F %H:%M:00'`" +%s)
TAG="1"
METRIC="cpu_temperature"
STEP=60

ENDPOINT=`cat /usr/local/open-falcon/agent/config/cfg.json | grep hostname  | awk -F'"' '{print $4}'`
if [ ! $ENDPOINT ]
then
	ENDPOINT=$HOSTNAME
fi



# 上传 Intel CPU 温度
function push_intel_temp {
	id=0
	for cpu_id in `ls /sys/class/thermal/ | grep thermal_zone`
	do
		VALUE=`expr \`cat /sys/class/thermal/$cpu_id/temp\` / 1000`
		TAG="id=$id"
		LIST[$id]="{\"endpoint\": \"$ENDPOINT\", \"tags\": \"$TAG\", \"timestamp\": $TS, \"metric\": \"$METRIC\", \"value\": $VALUE, \"counterType\": \"GAUGE\", \"step\": $STEP},"
		id=$(($id+1))
	done
}

# 上传 AMD CPU 温度，需要安装lm-sensors
function push_amd_temp {
	id=0
	for VALUE in `sensors | sed -n '/k10temp-/,+2p' | grep Tdie | awk -F[+°C] '{print $2}'`
	do
		TAG="id=$id"
		LIST[$id]="{\"endpoint\": \"$ENDPOINT\", \"tags\": \"$TAG\", \"timestamp\": $TS, \"metric\": \"$METRIC\", \"value\": $VALUE, \"counterType\": \"GAUGE\", \"step\": $STEP},"
		id=$(($id+1))
	done
}

# 判断cpu品牌
CPU=`cat /proc/cpuinfo | grep "model name" | awk -F'[ :(]+' '{print $3}' | uniq`

if [ "$CPU" == "Intel" ]
then
	push_intel_temp
elif [ "$CPU" == "AMD" ]
then
	push_amd_temp
fi

echo ${LIST[*]} | sed -e 's/{/[{/' -e 's/},$/}]/'