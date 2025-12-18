#!/bin/bash
set -e

REGION="us-east-1"

echo "🔥 Terminating EC2 instances..."
INSTANCE_IDS=$(aws ec2 describe-instances \
  --region $REGION \
  --query "Reservations[].Instances[].InstanceId" \
  --output text)

if [ -n "$INSTANCE_IDS" ]; then
  aws ec2 terminate-instances --region $REGION --instance-ids $INSTANCE_IDS
  echo "⏳ Waiting for EC2 termination..."
  aws ec2 wait instance-terminated --region $REGION --instance-ids $INSTANCE_IDS
fi

echo "🔥 Deleting Internet Gateways..."
IGWS=$(aws ec2 describe-internet-gateways \
  --region $REGION \
  --query "InternetGateways[].InternetGatewayId" \
  --output text)

for IGW in $IGWS; do
  VPCS=$(aws ec2 describe-internet-gateways \
    --region $REGION \
    --internet-gateway-ids $IGW \
    --query "InternetGateways[].Attachments[].VpcId" \
    --output text)

  for VPC in $VPCS; do
    aws ec2 detach-internet-gateway --region $REGION --internet-gateway-id $IGW --vpc-id $VPC
  done

  aws ec2 delete-internet-gateway --region $REGION --internet-gateway-id $IGW
done

echo "🔥 Deleting Subnets..."
SUBNETS=$(aws ec2 describe-subnets \
  --region $REGION \
  --query "Subnets[].SubnetId" \
  --output text)

for S in $SUBNETS; do
  aws ec2 delete-subnet --region $REGION --subnet-id $S
done

echo "🔥 Deleting Route Tables (non-main)..."
RTBS=$(aws ec2 describe-route-tables \
  --region $REGION \
  --query "RouteTables[?Associations[?Main==\`false\`]].RouteTableId" \
  --output text)

for R in $RTBS; do
  aws ec2 delete-route-table --region $REGION --route-table-id $R
done

echo "🔥 Deleting Security Groups (non-default)..."
SGS=$(aws ec2 describe-security-groups \
  --region $REGION \
  --query "SecurityGroups[?GroupName!='default'].GroupId" \
  --output text)

for SG in $SGS; do
  aws ec2 delete-security-group --region $REGION --group-id $SG || true
done

echo "🔥 Deleting VPCs..."
VPCS=$(aws ec2 describe-vpcs \
  --region $REGION \
  --query "Vpcs[].VpcId" \
  --output text)

for V in $VPCS; do
  aws ec2 delete-vpc --region $REGION --vpc-id $V
done

rm -f .*.id

echo "✅ AWS CLEANUP DONE"
