#!/bin/bash
set -e

echo "🚀 Creating EC2 Tools..."

PUBLIC_SUBNET_ID=$(cat ./env.sh)
SG_TOOLS=$(cat .sg_tools_id)

AMI_ID=ami-0e86e20dae9224db8
KEY_NAME=mykey
INSTANCE_TYPE=t3.medium

aws ec2 run-instances \
  --image-id $AMI_ID \
  --count 1 \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_NAME \
  --subnet-id $PUBLIC_SUBNET_ID \
  --security-group-ids $SG_TOOLS \
  --associate-public-ip-address \
  --user-data file://user-data/tools.sh \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=EC2-TOOLS}]'

echo "✅ EC2 TOOLS created"
