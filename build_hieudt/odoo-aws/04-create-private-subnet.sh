#!/bin/bash
source ./env.sh
VPC_ID=$(cat .vpc_id)

if [ -z "$VPC_ID" ]; then
  echo "❌ VPC_ID not found"
  exit 1
fi

echo "🚀 Creating Internet Gateway for $VPC_ID"
PRIVATE_SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $PRIVATE_SUBNET_CIDR \
  --availability-zone $AZ \
  --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=private-subnet}]" \
  --query "Subnet.SubnetId" \
  --output text)

echo "$PRIVATE_SUBNET_ID" > .private_subnet_id
echo "✅ Private subnet created $PRIVATE_SUBNET_ID"
