from datetime import date
import subprocess, os, json, random, string, time


instanceid=input("Enter Destination Instance ID: ").strip()
Region=input("Enter Region ID: ").strip()
unique_id=input("Enter Snapshot Unique ID: ").strip()
Date=str(date.today())

command_instance_name = "aws ec2 describe-instances --instance-ids "+instanceid+" --query \"Reservations[*].Instances[*].[Tags[?Key=='Name'].Value | [0], Tags[?Key=='Owner'].Value | [0], Placement.AvailabilityZone]\" --output text --region "+Region
instance_info = subprocess.check_output(command_instance_name, shell=True).strip().decode('ascii')
instance_name = instance_info.split()[0].strip()
instance_owner = instance_info.split()[1].strip()
instance_az = instance_info.split()[2].strip()

user_input = input("Do you want to continue for instance "+instance_name+"? (yes/no): ")

if user_input.lower() in ["yes", "y"]:
    command_snapshot_info = "aws ec2 describe-snapshots --filters \"Name=tag:UniqueID,Values="+unique_id+"\" --query \"Snapshots[*].[SnapshotId,Description,VolumeId]\"   --output text --region "+Region
    
    snapshot_info = subprocess.check_output(command_snapshot_info, shell=True).strip().decode('ascii')
    
    for snapshot in snapshot_info.split("\n"):
        snapshot_id = snapshot.split()[0]
        snapshot_device = snapshot.split()[5]
        snapshot_volumeid = snapshot.split()[10]
 
        command_ebs_details = "aws ec2 describe-volumes --volume-ids "+snapshot_volumeid+" --query \"Volumes[*].[VolumeId, Iops, Throughput]\" --output text --region "+Region
        ebs_details = subprocess.check_output(command_ebs_details, shell=True).strip().decode('ascii')
        ebs_iops = ebs_details.split()[1]
        ebs_throughput = ebs_details.split()[2]
        
        if snapshot_device not in [ "/dev/sda1", "/dev/sdf", "/dev/sdo" ]:
            print("Creating ebs volume for "+snapshot_id+" - "+snapshot_device+" - "+snapshot_volumeid)
            create_volume_command = "aws ec2 create-volume --availability-zone "+instance_az+" --snapshot-id "+snapshot_id+" --volume-type gp3 --throughput "+ebs_throughput+"  --iops "+ebs_iops+" --tag-specifications \"ResourceType=volume,Tags=[{Key=Name,Value="+instance_name+"-"+snapshot_device+"},{Key=InstanceID,Value="+instanceid+"},{Key=Device,Value="+snapshot_device+"},{Key=UniqueID,Value="+unique_id+"},{Key=Owner,Value="+instance_owner+"},{Key=Billing,Value="+instance_owner+"}]\" --region "+Region
            new_volumes_json = subprocess.check_output(create_volume_command, shell=True).strip().decode('ascii')
            new_volumes = json.loads(new_volumes_json)
            print("Created Volume: "+str(new_volumes["Tags"][0]))
            new_volumeid=new_volumes["VolumeId"]
            time.sleep(2) 
            os.system("aws ec2 attach-volume --device "+snapshot_device+" --instance-id "+instanceid+" --volume-id "+new_volumeid+" --output text --region "+Region)
        else:
            print("skipping "+snapshot_id+" - "+snapshot_device+" - "+snapshot_volumeid)

else:
    print("Exiting...")  