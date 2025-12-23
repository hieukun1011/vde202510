#!/bin/bash
source ./env.sh
VPC_ID=$(cat .vpc_id)
PRIVATE_SUBNET_ID=$(cat .private_subnet_id)
NAT_GW_ID=$(cat .nat_gw_id)
if [ -z "$VPC_ID" ]; then
  echo "❌ VPC_ID not found"
  exit 1
fi

echo "🚀 Creating Internet Gateway for $VPC_ID"
RT_PRIVATE_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=private-rt}]" \
  --query "RouteTable.RouteTableId" \
  --output text)

aws ec2 create-route \
  --route-table-id $RT_PRIVATE_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --nat-gateway-id $NAT_GW_ID \
  --region $REGION

echo "🚀 Creating associate-route-table for $RT_PRIVATE_ID and $PRIVATE_SUBNET_ID"
aws ec2 associate-route-table \
  --route-table-id $RT_PRIVATE_ID \
  --subnet-id $PRIVATE_SUBNET_ID

#echo "RT_PRIVATE_ID=$RT_PRIVATE_ID" >> env.sh
echo "✅ Private route table ready $RT_PRIVATE_ID"
