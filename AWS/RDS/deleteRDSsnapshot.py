import os, sys

if len(sys.argv) == 3:
    subaccount = sys.argv[1]
    region = sys.argv[2]
else:
    subaccount = input("Enter subaccount: ")   
    region = input("Enter region: ")


with open("objects.csv","r") as file:
    objects=file.read()


print("Using subaccount and region: "+subaccount+" "+region)

for item in objects.split("\n"):
    os.system('aws --profile '+subaccount+' rds describe-db-snapshots --db-snapshot-identifier '+item+' --region '+region+' > snapshot'+item)
    if os.stat('snapshot'+item).st_size==0:
        os.remove('snapshot'+item)
    else:
        os.remove('snapshot'+item)
        print("Deleting snapshot: "+item)
        os.system('aws --profile '+subaccount+' rds delete-db-snapshot --db-snapshot-identifier '+item+' --region '+region+' > deleted_snapshot_'+item)

################################

