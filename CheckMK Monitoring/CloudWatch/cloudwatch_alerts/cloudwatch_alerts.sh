cd /root/cloudwatch_alerts
while true
do

for account in `ls cred/*.cred`
do
for region in `cat regions`
do
account=`echo $account | awk -F"." '{print $1}' | awk -F"/" '{print $NF}'`
if [ ! -d alarms/$account ]
then
mkdir alarms/$account
fi
echo $account: $region
/usr/local/bin/aws --profile $account.cred cloudwatch describe-alarms --state-value "ALARM" --region $region | jq '.MetricAlarms[].AlarmName' > alarms/$account/$region &
done
sleep 15
done

sleep 60

done
