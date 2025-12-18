#!/bin/bash
set -e

AMI_ID="ami-0c02fb55956c7d316"
INSTANCE_TYPE="t3.medium"
KEY_NAME="mykey"

VPC_ID=$(aws ec2 describe-vpcs --filters Name=tag:Name,Values=odoo-vpc --query "Vpcs[0].VpcId" --output text)
PUBLIC_SUBNET_ID=$(aws ec2 describe-subnets --filters Name=tag:Name,Values=public-subnet --query "Subnets[0].SubnetId" --output text)
PRIVATE_SUBNET_ID=$(aws ec2 describe-subnets --filters Name=tag:Name,Values=private-subnet --query "Subnets[0].SubnetId" --output text)

# =====================
# SECURITY GROUPS
# =====================
SG_PUBLIC=$(aws ec2 create-security-group \
  --group-name public-sg \
  --description "Public SG" \
  --vpc-id $VPC_ID \
  --query GroupId --output text)

aws ec2 authorize-security-group-ingress --group-id $SG_PUBLIC --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SG_PUBLIC --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SG_PUBLIC --protocol tcp --port 443 --cidr 0.0.0.0/0

SG_DB=$(aws ec2 create-security-group \
  --group-name db-sg \
  --description "Postgres SG" \
  --vpc-id $VPC_ID \
  --query GroupId --output text)

aws ec2 authorize-security-group-ingress \
  --group-id $SG_DB \
  --protocol tcp \
  --port 5432 \
  --source-group $SG_PUBLIC

# =====================
# EC2 INSTANCES
# =====================
echo "🚀 Creating EC2 Odoo..."
aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_NAME \
  --subnet-id $PUBLIC_SUBNET_ID \
  --security-group-ids $SG_PUBLIC \
  --associate-public-ip-address \
  --user-data file://user_data/odoo.sh \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=odoo-app}]'

echo "🚀 Creating EC2 Tools..."
aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_NAME \
  --subnet-id $PUBLIC_SUBNET_ID \
  --security-group-ids $SG_PUBLIC \
  --associate-public-ip-address \
  --user-data file://user_data/tools.sh \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=devops-tools}]'

echo "🚀 Creating EC2 PostgreSQL..."
aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type t3.small \
  --key-name $KEY_NAME \
  --subnet-id $PRIVATE_SUBNET_ID \
  --security-group-ids $SG_DB \
  --user-data file://user_data/postgres.sh \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=postgres-db}]'
