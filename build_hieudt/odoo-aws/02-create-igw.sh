#!/bin/bash
set -e

source ./env.sh

VPC_ID=$(cat .vpc_id)

if [ -z "$VPC_ID" ]; then
  echo "❌ VPC_ID not found"
  exit 1
fi

echo "🚀 Creating Internet Gateway for $VPC_ID"

IGW_ID=$(aws ec2 create-internet-gateway \
  --region $REGION \
  --query 'InternetGateway.InternetGatewayId' \
  --output text)

aws ec2 attach-internet-gateway \
  --internet-gateway-id $IGW_ID \
  --vpc-id $VPC_ID \
  --region $REGION

aws ec2 create-tags \
  --resources $IGW_ID \
  --tags Key=Name,Value=$PROJECT-igw \
  --region $REGION

echo "$IGW_ID" > .igw_id

echo "✅ IGW attached: $IGW_ID"
