#!/bin/bash
set -e

VPC_ID=$(cat .vpc_id)

if [ -z "$VPC_ID" ]; then
  echo "❌ VPC_ID not found"
  exit 1
fi

echo "🚀 Creating Internet Gateway for $VPC_ID"
# Odoo SG
SG_ODOO=$(aws ec2 create-security-group \
  --group-name sg-odoo \
  --description "Odoo SG" \
  --vpc-id $VPC_ID \
  --query "GroupId" \
  --output text)

aws ec2 authorize-security-group-ingress \
  --group-id $SG_ODOO \
  --protocol tcp --port 22 --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
  --group-id $SG_ODOO \
  --protocol tcp --port 8069 --cidr 0.0.0.0/0

echo $SG_ODOO > .sg_odoo_id

# Postgres SG
SG_POSTGRES=$(aws ec2 create-security-group \
  --group-name sg-postgres \
  --description "Postgres SG" \
  --vpc-id $VPC_ID \
  --query "GroupId" \
  --output text)

aws ec2 authorize-security-group-ingress \
  --group-id $SG_POSTGRES \
  --protocol tcp --port 5432 --source-group $SG_ODOO

echo $SG_POSTGRES > .sg_postgres_id

# Tools SG
SG_TOOLS=$(aws ec2 create-security-group \
  --group-name sg-tools \
  --description "Tools SG" \
  --vpc-id $VPC_ID \
  --query "GroupId" \
  --output text)

aws ec2 authorize-security-group-ingress \
  --group-id $SG_TOOLS \
  --protocol tcp --port 22 --cidr 0.0.0.0/0

echo $SG_TOOLS > .sg_tools_id

echo "✅ Security groups created"
