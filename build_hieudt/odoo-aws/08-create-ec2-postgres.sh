#!/bin/bash
set -e

echo "🚀 Creating EC2 PostgreSQL..."

VPC_ID=$(cat ./env.sh)
PRIVATE_SUBNET_ID=$(cat .private_subnet_id)
SG_DB=$(cat .sg_postgres_id)

AMI_ID=ami-0e86e20dae9224db8   # Ubuntu 22.04 us-east-1
KEY_NAME=mykey
INSTANCE_TYPE=t3.medium

aws ec2 run-instances \
  --image-id $AMI_ID \
  --count 1 \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_NAME \
  --subnet-id $PRIVATE_SUBNET_ID \
  --security-group-ids $SG_DB \
  --user-data file://user-data/postgres.sh \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=EC2-POSTGRES}]'

echo "✅ EC2 POSTGRES created"
