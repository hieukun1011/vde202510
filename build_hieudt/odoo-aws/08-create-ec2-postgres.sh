#!/bin/bash
set -e

echo "🚀 Creating EC2 PostgreSQL..."

VPC_ID=$(cat .vpc_id)
[ -z "$VPC_ID" ] && echo "❌ VPC_ID not found" && exit 1

PRIVATE_SUBNET_ID=$(cat .private_subnet_id)
[ -z "$PRIVATE_SUBNET_ID" ] && echo "❌ PRIVATE_SUBNET_ID not found" && exit 1

SG_DB=$(cat .sg_postgres_id)
[ -z "$SG_DB" ] && echo "❌ SG_DB not found" && exit 1

SG_ODOO=$(cat .sg_odoo_id)
[ -z "$SG_ODOO" ] && echo "❌ SG_ODOO not found" && exit 1

echo "🔐 Allow SSH from Odoo to PostgreSQL"
aws ec2 authorize-security-group-ingress \
  --group-id $SG_DB \
  --protocol tcp \
  --port 22 \
  --source-group $SG_ODOO \
  || echo "⚠️ SSH rule already exists"

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
