#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
STEP=60

# push数据到falcon
function agent_push {
        METRIC=$1
        VALUE=$2
        TAGS=$3
        TS=$(date -d "`date +'%F %H:%M:00'`" +%s)
        if [ -f /writable/.deviceID ]
        then
                ENDPOINT=`cat /writable/.deviceID`
        else
                ENDPOINT=$HOSTNAME
        fi
        curl -m 15 -X POST -d "[{\"metric\": \"$METRIC\", \"endpoint\": \"$ENDPOINT\", \"timestamp\": $TS,\"step\": $STEP,\"value\": $VALUE,\"counterType\": \"GAUGE\",\"tags\": \"$TAGS\"}]" http://127.0.0.1:1988/v1/push > /dev/null 2>&1
}

###
TS=$(date -d "`date +'%F %H:%M:00'`" +%s)
echo "[{\"endpoint\": \"$HOSTNAME\", \"tags\": \"test=test1\", \"timestamp\": $TS, \"metric\": \"test.test1\", \"value\": 9, \"counterType\": \"GAUGE\", \"step\": 60}, {\"endpoint\": \"$HOSTNAME\", \"tags\": \"test=test2\", \"timestamp\": $TS, \"metric\": \"test.test1\", \"value\": 9, \"counterType\": \"GAUGE\", \"step\": 60}]"
