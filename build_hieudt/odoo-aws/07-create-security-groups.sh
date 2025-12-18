#!/bin/bash
source ./env.sh

# Odoo SG
SG_ODOO=$(aws ec2 create-security-group \
  --group-name odoo-sg \
  --description "Odoo SG" \
  --vpc-id $VPC_ID \
  --query "GroupId" \
  --output text)

aws ec2 authorize-security-group-ingress --group-id $SG_ODOO --protocol tcp --port 8069 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SG_ODOO --protocol tcp --port 22 --cidr 0.0.0.0/0

echo "SG_ODOO=$SG_ODOO" >> env.sh

# Postgres SG
SG_PG=$(aws ec2 create-security-group \
  --group-name pg-sg \
  --description "Postgres SG" \
  --vpc-id $VPC_ID \
  --query "GroupId" \
  --output text)

aws ec2 authorize-security-group-ingress \
  --group-id $SG_PG \
  --protocol tcp --port 5432 \
  --source-group $SG_ODOO

echo "SG_PG=$SG_PG" >> env.sh

echo "✅ Security groups created"
