#!/bin/bash
source ./env.sh
VPC_ID=$(cat .vpc_id)
IGW_ID=$(cat .igw_id)
PUBLIC_SUBNET_ID=$(cat .public_subnet_id)

if [ -z "$VPC_ID" ]; then
  echo "❌ VPC_ID not found"
  exit 1
fi

echo "🚀 Creating Internet Gateway for $VPC_ID"
RT_PUBLIC_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=public-rt}]" \
  --query "RouteTable.RouteTableId" \
  --output text)

echo "🚀 Creating create-route for $RT_PUBLIC_ID"
aws ec2 create-route \
  --route-table-id $RT_PUBLIC_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW_ID

echo "🚀 Creating associate-route-table for route-table-id $RT_PUBLIC_ID subnet-id $PUBLIC_SUBNET_ID"
aws ec2 associate-route-table \
  --route-table-id $RT_PUBLIC_ID \
  --subnet-id $PUBLIC_SUBNET_ID

echo "RT_PUBLIC_ID=$RT_PUBLIC_ID" >> env.sh
echo "✅ Public route table ready $RT_PUBLIC_ID"
