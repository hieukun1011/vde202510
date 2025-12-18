#!/bin/bash
source ./env.sh

echo "🚀 Creating VPC..."

VPC_ID=$(aws ec2 create-vpc \
  --cidr-block $VPC_CIDR \
  --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=$PROJECT-vpc}]" \
  --query "Vpc.VpcId" \
  --output text)

aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-support
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames

echo "VPC_ID=$VPC_ID" >> .vpc_id
echo "✅ VPC created: $VPC_ID"
