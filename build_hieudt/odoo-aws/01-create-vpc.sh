#!/bin/bash
set -e

source ./env.sh

echo "🚀 Creating VPC..."

VPC_ID=$(aws ec2 create-vpc \
  --region $REGION \
  --cidr-block $VPC_CIDR \
  --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=$PROJECT-vpc}]" \
  --query "Vpc.VpcId" \
  --output text)

aws ec2 modify-vpc-attribute \
  --region $REGION \
  --vpc-id $VPC_ID \
  --enable-dns-support "{\"Value\":true}"

aws ec2 modify-vpc-attribute \
  --region $REGION \
  --vpc-id $VPC_ID \
  --enable-dns-hostnames "{\"Value\":true}"

echo $VPC_ID > .vpc_id

echo "✅ VPC created: $VPC_ID"
