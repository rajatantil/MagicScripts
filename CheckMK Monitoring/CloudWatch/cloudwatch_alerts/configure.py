import json, os

os.system("/usr/local/bin/aws organizations list-accounts > cred/accounts")

ROLE=""

with open("cred/accounts","r") as file:
        output = file.read()

accounts = json.loads(output)
for value in accounts['Accounts']:
        Name=value['Name'].replace(" ","_")
        os.system("/usr/local/bin/aws sts assume-role --role-arn arn:aws:iam::"+value['Id']+":role/"+ROLE+"  --role-session-name CheckMK --endpoint-url https://sts.us-east-1.amazonaws.com --region us-east-1 --duration-seconds 3600 > cred/"+Name+".cred")
        if os.stat("cred/"+Name+".cred").st_size==0:
                os.remove("cred/"+Name+".cred")
        else:
                with open("cred/"+Name+".cred","r") as file:
                        credout = file.read()
                        cred = json.loads(credout)
                        os.system("/usr/local/bin/aws configure --profile "+Name+".cred set aws_access_key_id "+cred["Credentials"]["AccessKeyId"])
                        os.system("/usr/local/bin/aws configure --profile "+Name+".cred set aws_secret_access_key "+cred["Credentials"]["SecretAccessKey"])
                        os.system("/usr/local/bin/aws configure --profile "+Name+".cred set aws_session_token "+cred["Credentials"]["SessionToken"])

print("Configure Script completed")
