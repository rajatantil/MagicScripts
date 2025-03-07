RDSInstance=$1
Account=$2
Region=$3
RDSEngine=$4
LatestEngine=$5
DATE=`date +%d%b%y`

if [[ -z $5 ]]; then
        echo "Arguments not found ./PatchRDS.sh <RDSInstance> <Account> <Region> <RDSEngine> <LatestEngine>"
        exit
fi


create_rds_snapshot () {
count=0
while true
do
count=$[$count+1]
aws --profile ${Account}.cred rds create-db-snapshot --db-snapshot-identifier ${RDSInstance}-before-patching-${DATE} --db-instance-identifier $RDSInstance --region $Region
if [ $? -eq 0 ]
then
echo "Snapshot creation in progress"
break
fi
if [ $count -eq 30 ]
then
echo "Tried 30 times.. quitting.."
break
fi
sleep 10
done
}

monitor_rds_status () {
sleep 120
DBStatus=$(aws --profile ${Account}.cred rds describe-db-instances --db-instance-identifier $RDSInstance --region $Region --query "DBInstances[*].DBInstanceStatus" --output text)
echo "DB Status: $RDSInstance $DBStatus"
while [ "$DBStatus" != "available" ]
do
  if [[ "$DBStatus" == "" ]]
  then
  echo "DB Status: $RDSInstance Not found.."
  exit
  fi
  sleep 180
  DBStatus=$(aws --profile ${Account}.cred rds describe-db-instances --db-instance-identifier $RDSInstance --region $Region --query "DBInstances[*].DBInstanceStatus" --output text)
  echo "DB Status: $RDSInstance $DBStatus"
done
}

monitor_rds_snapshot_status () {
sleep 30
SnapshotStatus=$(aws --profile ${Account}.cred rds describe-db-snapshots --db-snapshot-identifier ${RDSInstance}-before-patching-${DATE} --region $Region --query "DBSnapshots[*].Status" --output text)
echo "DB Snapshot Status: ${RDSInstance}-before-patching-${DATE} $SnapshotStatus"
while [ "$SnapshotStatus" != "available" ]
do
  if [[ "$SnapshotStatus" == "" ]]
  then
  echo "DB Snapshot Status: ${RDSInstance}-before-patching-${DATE} Not found.."
  exit
  fi
  sleep 60
  SnapshotStatus=$(aws --profile ${Account}.cred rds describe-db-snapshots --db-snapshot-identifier ${RDSInstance}-before-patching-${DATE} --region $Region --query "DBSnapshots[*].Status" --output text)
  echo "DB Snapshot Status: ${RDSInstance}-before-patching-${DATE} $SnapshotStatus"
done
}


CurrentEngine=`aws --profile ${Account}.cred rds describe-db-instances --db-instance-identifier $RDSInstance --query DBInstances[].EngineVersion[] --region $Region --output text`
#LatestEngine=`aws --profile ${Account}.cred rds describe-db-engine-versions --engine $RDSEngine --engine-version $CurrentEngine --region $Region --query "DBEngineVersions[*].ValidUpgradeTarget[*].{EngineVersion:EngineVersion}" --output text | tail -1`


echo "Current engine is $CurrentEngine"
echo "Latest engine is $LatestEngine"

if [[ "$LatestEngine" == "" ]]
then
        echo "No LatestEngine found exiting.."
        exit
fi

if [[ "$CurrentEngine" == "" ]]
then
        echo "No CurrentEngine found exiting.."
        exit
fi


if [ "$CurrentEngine" == "$LatestEngine" ]
then
echo "RDS instance $RDSInstance already at latest version $LatestEngine"
else
create_rds_snapshot
monitor_rds_snapshot_status
monitor_rds_status
echo "Modifying instance $RDSInstance from $CurrentEngine to $LatestEngine"
aws --profile ${Account}.cred rds modify-db-instance --db-instance-identifier $RDSInstance --engine-version $LatestEngine --no-allow-major-version-upgrade --apply-immediately --region $Region
if [ $? -gt 0 ]
then
echo "Error trying to modify the instance $RDSInstance"
exit
fi
monitor_rds_status
echo "RDS instance $RDSInstance upgraded to latest version $LatestEngine"
fi