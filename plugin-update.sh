#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin


PLUGIN_DIR=/usr/local/open-falcon/plugin/
RANDOM_SLEEP=`echo $(($RANDOM%3000))`


sleep $RANDOM_SLEEP
cd $PLUGIN_DIR
git reset --hard
git reset --hard origin/master

curl http://127.0.0.1:1988/plugin/update

for SCRIPT_LIST in `find $PLUGIN_DIR -name "*" | grep -E "*.sh$|*.py$" `
do
        chmod +x $SCRIPT_LIST
done