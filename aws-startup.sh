#!/bin/bash

#==========================CREDENTIALS AND CONFIGS===================

#AWS credentials folder
AWS_CRED_DIR="INPUT YOUR CREDS" 
#AWS access key id
AWS_ACCESS_KEY_ID="INPUT YOUR CREDS"
#AWS secret key
AWS_SECRET_ACCESS_KEY="INPUT YOUR CREDS"
#AWS region of instance
AWS_DEFAULT_REGION="INPUT YOUR CREDS"
#AWS output format
AWS_DEFAULT_FORMAT="INPUT YOUR CREDS"

#====================================================================

echo "Starting... \n"

if [ ! -f $AWS_CRED_DIR ]; then
    aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
    aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
    aws configure set default.region $AWS_DEFAULT_REGION
    aws configure set default.output $AWS_DEFAULT_FORMAT
fi

CURRENT_AWS_STATE=$(aws ec2 describe-instance-status --instance-id $1 | jq -r '.InstanceStatuses[0].SystemStatus.Status')

if [ $CURRENT_AWS_STATE != null ]; then
    echo "This AWS instance already running"
    exit -1
fi

aws ec2 start-instances --instance-ids $1

#==================STARTING AWS INSTANCE=============================

AWS_STATE="0" #default state(Actually in stopped state AWS don't send status)
AWS_RUNNING_STATE="ok"

echo "Waiting for server to start..."

until [ $AWS_STATE == $AWS_RUNNING_STATE ]
do
    AWS_STATE=$(aws ec2 describe-instance-status --instance-id $1 | jq -r '.InstanceStatuses[0].SystemStatus.Status')
done

#====================================================================

AWS_HOST="ubuntu@"
AWS_HOST+=$(aws ec2 describe-instances --instance-id $1 | jq -r '.Reservations[0].Instances[0].NetworkInterfaces[0].Association.PublicIp')

echo "Start initials jobs..."

INIT_SCRIPT="INPUT YOUR SCRIPT"
ssh -i $2 $AWS_HOST $INIT_SCRIPT
