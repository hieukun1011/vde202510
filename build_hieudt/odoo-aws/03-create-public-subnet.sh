#!/bin/bash
source ./env.sh
VPC_ID=$(cat .vpc_id)

if [ -z "$VPC_ID" ]; then
  echo "❌ VPC_ID not found"
  exit 1
fi

echo "🚀 Creating Internet Gateway for $VPC_ID"
PUBLIC_SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $PUBLIC_SUBNET_CIDR \
  --availability-zone $AZ \
  --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=public-subnet}]" \
  --query "Subnet.SubnetId" \
  --output text)

aws ec2 modify-subnet-attribute \
  --subnet-id $PUBLIC_SUBNET_ID \
  --map-public-ip-on-launch

echo "PUBLIC_SUBNET_ID=$PUBLIC_SUBNET_ID" >> .public_subnet_id
echo "✅ Public subnet created $PUBLIC_SUBNET_ID"
