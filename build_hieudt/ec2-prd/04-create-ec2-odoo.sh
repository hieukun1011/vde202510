#!/bin/bash
set -e
source ./00-env.sh
source .env

echo "🚀 Creating Odoo EC2..."

INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_NAME \
  --subnet-id $PUBLIC_SUBNET_ID \
  --security-group-ids $SG_ODDO \
  --user-data file://user-data/odoo.sh \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=odoo-app}]' \
  --query 'Instances[0].InstanceId' \
  --output text)

aws ec2 wait instance-running --instance-ids $INSTANCE_ID

PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

echo "ODDO_PUBLIC_IP=$PUBLIC_IP" >> .env

echo "✅ Odoo EC2 ready"
echo "🌍 URL: http://$PUBLIC_IP:8069"
