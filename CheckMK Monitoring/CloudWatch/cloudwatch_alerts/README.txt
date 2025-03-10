1) Create folder in /root/cloudwatch_alerts

2) Setup cron as per below:
00 * * * * cd /root/cloudwatch_alerts && python3 configure.py > configure.log 2>&1
*/5 * * * * cd /root/cloudwatch_alerts && sh start.sh

3) Copy and rename _script_in_checkmk_local.sh in check mk local folder.

4) Set ROLE variable in script configure.py