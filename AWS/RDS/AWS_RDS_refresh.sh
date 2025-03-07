ProductionRDS=""
TargetRDS=""
RestoreTime="YYYY-MM-DDTHH:MM:SSZ"
DBName=""
Region="eu-central-1"
AZ="eu-central-1"
TargetRDSSize="db.r5.xlarge"
TargetRDSPort="1524"
TargetRDSSubnetGroup=""
TargetRDSOptionGroup=""
TargetRDSParameterGroup=""
VPC_SG1=""
VPC_SG2=""
Owner_Tag=""
Name_Tag=""

create_rds () {
echo "creating $TargetRDS RDS"
aws rds restore-db-instance-to-point-in-time  \
 --source-db-instance-identifier $ProductionRDS \
 --target-db-instance-identifier $TargetRDS \
 --restore-time $RestoreTime \
 --db-name $DBName \
 --region $Region \
 --db-instance-class $TargetRDSSize \
 --port $TargetRDSPort \
 --storage-type gp2 \
 --availability-zone $AZ \
 --no-multi-az \
 --db-subnet-group-name $TargetRDSSubnetGroup \
 --no-publicly-accessible \
 --no-auto-minor-version-upgrade \
 --no-deletion-protection \
 --option-group-name $TargetRDSOptionGroup \
 --vpc-security-group-ids  $VPC_SG1 $VPC_SG2 \
 --db-parameter-group-name $TargetRDSParameterGroup \
 --tags "Key=Owner,Value=$Owner_Tag" "Key=Name,Value=$Name_Tag"
}


monitor_status () {
DBStatus=$(aws rds describe-db-instances --db-instance-identifier $TargetRDS --region $Region --query "DBInstances[*].DBInstanceStatus" --output text)

while [ "$DBStatus" != "available" ]
do
  if [[ "$DBStatus" == "" ]]
  then
  echo "DB Status: $TargetRDS Not found.."
  break
  fi
  echo "DB Status: $TargetRDS $DBStatus"
  sleep 180
  DBStatus=$(aws rds describe-db-instances --db-instance-identifier $TargetRDS --region $Region --query "DBInstances[*].DBInstanceStatus" --output text)
done
}


delete_rds () {
echo "Deleting existing RDS"
aws rds delete-db-instance --db-instance-identifier $TargetRDS --skip-final-snapshot --delete-automated-backups --region $Region
}


modify_rds () {
echo "Modifying Target RDS Backup Retention to 1"
aws rds modify-db-instance --db-instance-identifier $TargetRDS --backup-retention-period 1 --region $Region
}


echo "Looking for Existing $TargetRDS instance"
result=`aws rds describe-db-instances --db-instance-identifier $TargetRDS --region $Region`
if [ -z "$result" ]
then
echo "$TargetRDS not found"
create_rds
monitor_status
modify_rds
else
echo "$TargetRDS found"
delete_rds
aws rds wait db-instance-deleted --db-instance-identifier $TargetRDS --region $Region
create_rds
monitor_status
modify_rds
fi
