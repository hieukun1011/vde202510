#!/bin/bash
set -e

REGION="us-east-1"

echo "🔥 Terminating EC2..."
IDS=$(aws ec2 describe-instances \
  --region $REGION \
  --query "Reservations[].Instances[].InstanceId" \
  --output text)

[ -n "$IDS" ] && aws ec2 terminate-instances --region $REGION --instance-ids $IDS
[ -n "$IDS" ] && aws ec2 wait instance-terminated --region $REGION --instance-ids $IDS

echo "🔥 Deleting NAT Gateways..."
NATS=$(aws ec2 describe-nat-gateways \
  --region $REGION \
  --query "NatGateways[].NatGatewayId" \
  --output text)

for N in $NATS; do
  aws ec2 delete-nat-gateway --region $REGION --nat-gateway-id $N
done

echo "🔥 Waiting NAT delete..."
sleep 60

echo "🔥 Deleting ENIs..."
ENIS=$(aws ec2 describe-network-interfaces \
  --region $REGION \
  --query "NetworkInterfaces[].NetworkInterfaceId" \
  --output text)

for E in $ENIS; do
  aws ec2 delete-network-interface --region $REGION --network-interface-id $E || true
done

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
  for V in $VPCS; do
    aws ec2 detach-internet-gateway --region $REGION --internet-gateway-id $IGW --vpc-id $V
  done
  aws ec2 delete-internet-gateway --region $REGION --internet-gateway-id $IGW
done

echo "🔥 Deleting Route Tables (non-main)..."
RTS=$(aws ec2 describe-route-tables \
  --region $REGION \
  --query "RouteTables[?Associations[?Main==\`false\`]].RouteTableId" \
  --output text)

for R in $RTS; do
  aws ec2 delete-route-table --region $REGION --route-table-id $R
done

echo "🔥 Deleting Subnets..."
SUBNETS=$(aws ec2 describe-subnets \
  --region $REGION \
  --query "Subnets[].SubnetId" \
  --output text)

for S in $SUBNETS; do
  aws ec2 delete-subnet --region $REGION --subnet-id $S
done

echo "🔥 Deleting Security Groups..."
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

echo "✅ AWS CLEANED COMPLETELY"
