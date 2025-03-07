from datetime import date
import subprocess, os, json, random, string, time


def generate_unique_id():
    prefix = "A2R-"
    alphanumeric_code = ''.join(random.choices(string.ascii_uppercase + string.digits, k=8))
    unique_id = prefix + alphanumeric_code
    return unique_id

instanceid=input("Enter Instance ID: ").strip()
Region=input("Enter Region ID: ").strip()
Date=str(date.today())

command_instance_name = "aws ec2 describe-instances --instance-ids "+instanceid+" --query \"Reservations[*].Instances[*].Tags[?Key=='Name'].Value[]\" --output text --region "+Region
instance_name = subprocess.check_output(command_instance_name, shell=True).strip().decode('ascii')

user_input = input("Do you want to continue for instance "+instance_name+"? (yes/no): ")

if user_input.lower() in ["yes", "y"]:
    unique_id = generate_unique_id()
    print("Generated Unique ID:", unique_id)
    command_ebs_info = "aws ec2 describe-instances --instance-ids "+instanceid+" --query \"Reservations[].Instances[].BlockDeviceMappings[].[Ebs.VolumeId, DeviceName]\" --output json --region "+Region
    device_info_json = subprocess.check_output(command_ebs_info, shell=True).strip().decode('ascii')
    device_info = json.loads(device_info_json)
    
    for volume in device_info:
        print("Creating snapshot for "+instance_name+" - "+instanceid+" - "+volume[1])
        os.system("aws ec2 create-snapshot --volume-id "+volume[0]+" --description \""+instance_name+" - "+instanceid+" - "+volume[1]+" - "+Date+" - "+unique_id+"\" --tag-specifications \"ResourceType=snapshot,Tags=[{Key=Name,Value="+instance_name+"},{Key=InstanceID,Value="+instanceid+"},{Key=VolumeID,Value="+volume[0]+"},{Key=Device,Value="+volume[1]+"},{Key=UniqueID,Value="+unique_id+"}]\" --region "+Region+" > LOGS/"+volume[0])
    
    time.sleep(5)
    os.system("aws ec2 describe-snapshots --filters \"Name=tag:UniqueID,Values="+unique_id+"\"  --output text --region "+Region)
    
    
    #os.system("aws ec2 create-snapshots --instance-specification InstanceId="+instanceid+" --copy-tags-from-source volume --description \""+instance_name+" - "+instanceid+" - "+Date+"\" --region "+Region)
else:
    print("Exiting...")
