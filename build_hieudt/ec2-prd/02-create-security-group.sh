#!/bin/bash
set -e
source ./00-env.sh
source .env

SG_ODDO=$(aws ec2 create-security-group \
  --group-name odoo-sg \
  --description odoo \
  --vpc-id $VPC_ID \
  --query 'GroupId' \
  --output text)

aws ec2 authorize-security-group-ingress --group-id $SG_ODDO --protocol tcp --port 8069 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SG_ODDO --protocol tcp --port 22 --cidr 0.0.0.0/0

SG_DB=$(aws ec2 create-security-group \
  --group-name postgres-sg \
  --description postgres \
  --vpc-id $VPC_ID \
  --query 'GroupId' \
  --output text)

aws ec2 authorize-security-group-ingress \
  --group-id $SG_DB \
  --protocol tcp \
  --port 5432 \
  --source-group $SG_ODDO

echo "SG_ODDO=$SG_ODDO" >> .env
echo "SG_DB=$SG_DB" >> .env

echo "✅ Security groups created"
