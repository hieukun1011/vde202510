#!/bin/bash
source ./env.sh

RT_PRIVATE_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=private-rt}]" \
  --query "RouteTable.RouteTableId" \
  --output text)

aws ec2 associate-route-table \
  --route-table-id $RT_PRIVATE_ID \
  --subnet-id $PRIVATE_SUBNET_ID

echo "RT_PRIVATE_ID=$RT_PRIVATE_ID" >> env.sh
echo "✅ Private route table ready"
