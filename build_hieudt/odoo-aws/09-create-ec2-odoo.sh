#!/bin/bash
set -e

echo "🚀 Creating EC2 Odoo..."

PUBLIC_SUBNET_ID=$(cat .public_subnet_id)
SG_ODOO=$(cat .sg_odoo_id)

AMI_ID=ami-0e86e20dae9224db8
KEY_NAME=mykey
INSTANCE_TYPE=t3.large

aws ec2 run-instances \
  --image-id $AMI_ID \
  --count 1 \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_NAME \
  --subnet-id $PUBLIC_SUBNET_ID \
  --security-group-ids $SG_ODOO \
  --associate-public-ip-address \
  --user-data file://user-data/odoo.sh \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=EC2-ODOO}]'

echo "✅ EC2 ODOO created"
