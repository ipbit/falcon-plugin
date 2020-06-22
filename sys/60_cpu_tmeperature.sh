#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

TS=$(date -d "`date +'%F %H:%M:00'`" +%s)
# 上传 Intel CPU 温度
function push_intel_temp {
	id=0
	for cpu_id in `ls /sys/class/thermal/ | grep thermal_zone`
	do
		TEMP=`expr \`cat /sys/class/thermal/$cpu_id/temp\` / 1000`
		LIST[$id]="{\"endpoint\": \"$HOSTNAME\", \"tags\": \"id=$id\“, \"timestamp\": $TS, \"metric\": \"cpu_temperature\", \"value\": $TEMP, \"counterType\": \"GAUGE\", \"step\": 60},"
		id=$(($id+1))
	done
}

# 上传 AMD CPU 温度，需要安装lm-sensors
function push_amd_temp {
	id=0
	for TEMP in `sensors | sed -n '/k10temp-/,+2p' | grep Tdie | awk -F[+°C] '{print $2}'`
	do
		LIST[$id]="{\"endpoint\": \"$HOSTNAME\", \"tags\": \"id=$id\", \"timestamp\": $TS, \"metric\": \"cpu_temperature\", \"value\": $TEMP, \"counterType\": \"GAUGE\", \"step\": 60},"
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