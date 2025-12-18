#!/bin/bash
set -e

echo "🚀 Creating EC2 PostgreSQL..."

VPC_ID=$(cat .vpc_id)

if [ -z "$VPC_ID" ]; then
  echo "❌ VPC_ID not found"
  exit 1
fi

echo "🚀 Creating Internet Gateway for $VPC_ID"

PRIVATE_SUBNET_ID=$(cat .private_subnet_id)

if [ -z "PRIVATE_SUBNET_ID" ]; then
  echo "❌ PRIVATE_SUBNET_ID not found"
  exit 1
fi

echo "🚀 Creating Internet Gateway for PRIVATE_SUBNET_ID"
SG_DB=$(cat .sg_postgres_id)

if [ -z "SG_DB" ]; then
  echo "❌ SG_DB not found"
  exit 1
fi

echo "🚀 Creating Internet Gateway for SG_DB"

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
