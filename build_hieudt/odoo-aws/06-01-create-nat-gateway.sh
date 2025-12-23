#!/bin/bash
set -e

source ./env.sh

PUBLIC_SUBNET_ID=$(cat .public_subnet_id)

EIP_ALLOC_ID=$(aws ec2 allocate-address \
  --domain vpc \
  --region $REGION \
  --query "AllocationId" \
  --output text)



NAT_GW_ID=$(aws ec2 create-nat-gateway \
  --subnet-id $PUBLIC_SUBNET_ID \
  --allocation-id $EIP_ALLOC_ID \
  --region $REGION \
  --query "NatGateway.NatGatewayId" \
  --output text)

echo "$NAT_GW_ID" > .nat_gw_id

aws ec2 wait nat-gateway-available \
  --nat-gateway-ids $NAT_GW_ID \
  --region $REGION

