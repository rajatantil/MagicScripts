cd /root/cloudwatch_alerts/alarms

for account in `ls`
do

cd $account
result=`find . -type f -size +0`

if [ -z "$result" ]
then
echo "0 ${account}_cloudwatch_alarm - OK"
else
text=""
for file in `find . -type f -size +0`
do
filename=`echo $file | awk -F"/" '{print $NF}'`
for line in `cat $file`
do
text="$text $filename:$line"
done
done
echo "2 ${account}_cloudwatch_alarm - $text"
fi

cd ..
done
