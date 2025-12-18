#!/bin/bash
set -e
source ./00-env.sh
source .env

echo "🚀 Creating PostgreSQL EC2..."

INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_NAME \
  --subnet-id $PRIVATE_SUBNET_ID \
  --security-group-ids $SG_DB \
  --user-data file://user-data/postgres.sh \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=postgres-db}]' \
  --query 'Instances[0].InstanceId' \
  --output text)

aws ec2 wait instance-running --instance-ids $INSTANCE_ID

PRIVATE_IP=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query 'Reservations[0].Instances[0].PrivateIpAddress' \
  --output text)

echo "POSTGRES_PRIVATE_IP=$PRIVATE_IP" >> .env

echo "✅ PostgreSQL EC2 created: $PRIVATE_IP"
