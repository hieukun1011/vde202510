#!/bin/bash
source ./env.sh

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

echo "PUBLIC_SUBNET_ID=$PUBLIC_SUBNET_ID" >> env.sh
echo "✅ Public subnet created"
