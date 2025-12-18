#!/bin/bash
source ./env.sh

RT_PUBLIC_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=public-rt}]" \
  --query "RouteTable.RouteTableId" \
  --output text)

aws ec2 create-route \
  --route-table-id $RT_PUBLIC_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW_ID

aws ec2 associate-route-table \
  --route-table-id $RT_PUBLIC_ID \
  --subnet-id $PUBLIC_SUBNET_ID

echo "RT_PUBLIC_ID=$RT_PUBLIC_ID" >> env.sh
echo "✅ Public route table ready"
