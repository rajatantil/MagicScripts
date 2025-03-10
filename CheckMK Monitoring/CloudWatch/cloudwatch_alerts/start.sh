if [ -z "`ps -ef | grep -i cloudwatch_alerts.sh | grep -v grep`" ]
then
        echo "Starting script"
        cd /root/cloudwatch_alerts
        nohup ./cloudwatch_alerts.sh > nohup.out 2>&1 &
else
        echo "Nope! Already Running"
fi

