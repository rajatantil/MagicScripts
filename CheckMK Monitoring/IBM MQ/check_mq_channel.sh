#!/bin/bash

###############################
#SCRIPT TO MONITOR MQ CHANNEL
# check_mq_channel_actual
#################################

> /tmp/channel_status

for QMANAGERS in `/opt/mqm/bin/dspmq | /usr/bin/awk '{print $1}' | sed -e 's/QMNAME(//' -e 's/)//'`
do
for i in `echo "dis chstatus(*)" | /opt/mqm/bin/runmqsc $QMANAGERS | grep CHANNEL | grep -v "CHLTYPE(SVRCONN)" | awk -F"(" '{print $2}' | awk -F")" '{print $1}'`
do
channel_status=`echo "dis chstatus($i)" | /opt/mqm/bin/runmqsc $QMANAGERS | grep STATUS | awk -F"(" '{print $3}' | awk -F")" '{print $1}'`

if [ $channel_status != "RUNNING" ]
then
echo -n "$i is $channel_status | " >> /tmp/channel_status
fi

done
done

if [ -s /tmp/channel_status ]
then
echo "2 check_mq_channel - CRITICAL | `cat /tmp/channel_status`"
else
echo "0 check_mq_channel - ALL CHANNELS LOOK OK"
fi
