import os, json

IAM_Role = input("Enter IAM role: ")

os.system("aws organizations list-accounts > accounts.json")

with open("accounts.json","r") as file:
    output = file.read()
    
accounts = json.loads(output)

for subaccount in accounts['Accounts']:
    os.system("aws sts assume-role --role-arn arn:aws:iam::"+subaccount['Id']+":role/"+IAM_Role+" --role-session-name session_"+os.getlogin().lower()+" --endpoint-url https://sts.us-east-1.amazonaws.com --region us-east-1 > session")
    if os.stat("session").st_size==0:
        os.remove("session")
    else:
        with open("session","r") as file:
            credout = file.read()
        cred = json.loads(credout)
        os.system("aws configure --profile "+subaccount['Id']+".cred set aws_access_key_id "+cred["Credentials"]["AccessKeyId"])
        os.system("aws configure --profile "+subaccount['Id']+".cred set aws_secret_access_key "+cred["Credentials"]["SecretAccessKey"])
        os.system("aws configure --profile "+subaccount['Id']+".cred set aws_session_token "+cred["Credentials"]["SessionToken"])
        print("Welcome to Subaccount: "+subaccount['Id'])
        os.remove("session")

os.remove("accounts.json")