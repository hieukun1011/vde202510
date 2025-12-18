#!/bin/bash
set -e
REGION="us-east-1"

echo "⏳ Terminating all EC2 instances..."
INSTANCES=$(aws ec2 describe-instances --region $REGION \
  --query "Reservations[].Instances[].InstanceId" --output text)

if [ -n "$INSTANCES" ]; then
  aws ec2 terminate-instances --instance-ids $INSTANCES --region $REGION
  aws ec2 wait instance-terminated --instance-ids $INSTANCES --region $REGION
fi

echo "🔥 Deleting Load Balancers..."
aws elbv2 describe-load-balancers --region $REGION \
  --query "LoadBalancers[].LoadBalancerArn" --output text | while read lb; do
    [ -n "$lb" ] && aws elbv2 delete-load-balancer --load-balancer-arn "$lb" --region $REGION
done

echo "🔥 Deleting NAT Gateways..."
aws ec2 describe-nat-gateways --region $REGION \
  --query "NatGateways[].NatGatewayId" --output text | while read nat; do
    [ -n "$nat" ] && aws ec2 delete-nat-gateway --nat-gateway-id "$nat" --region $REGION
done

sleep 30

echo "🔥 Deleting Network Interfaces (ENI)..."
aws ec2 describe-network-interfaces --region $REGION \
  --query "NetworkInterfaces[].NetworkInterfaceId" --output text | while read eni; do
    [ -n "$eni" ] && aws ec2 delete-network-interface --network-interface-id "$eni" --region $REGION || true
done

echo "🔥 Deleting Security Groups (non-default)..."
aws ec2 describe-security-groups --region $REGION \
  --query "SecurityGroups[?GroupName!='default'].GroupId" --output text | while read sg; do
    [ -n "$sg" ] && aws ec2 delete-security-group --group-id "$sg" --region $REGION || true
done

echo "🔥 Detaching & deleting Internet Gateways..."
aws ec2 describe-internet-gateways --region $REGION \
  --query "InternetGateways[].InternetGatewayId" --output text | while read igw; do
    vpc=$(aws ec2 describe-internet-gateways \
      --internet-gateway-ids "$igw" \
      --query "InternetGateways[0].Attachments[0].VpcId" \
      --output text --region $REGION)

    if [ "$vpc" != "None" ] && [ -n "$vpc" ]; then
      aws ec2 detach-internet-gateway --internet-gateway-id "$igw" --vpc-id "$vpc" --region $REGION
    fi
    aws ec2 delete-internet-gateway --internet-gateway-id "$igw" --region $REGION
done

echo "🔥 Deleting Subnets..."
aws ec2 describe-subnets --region $REGION \
  --query "Subnets[].SubnetId" --output text | while read subnet; do
    [ -n "$subnet" ] && aws ec2 delete-subnet --subnet-id "$subnet" --region $REGION || true
done

echo "🔥 Deleting Route Tables (non-main)..."
aws ec2 describe-route-tables --region $REGION \
  --query "RouteTables[?Associations[?Main==\`false\`]].RouteTableId" \
  --output text | while read rt; do
    [ -n "$rt" ] && aws ec2 delete-route-table --route-table-id "$rt" --region $REGION || true
done

echo "🔥 Deleting VPCs (non-default)..."
aws ec2 describe-vpcs --region $REGION \
  --query "Vpcs[?IsDefault==\`false\`].VpcId" --output text | while read vpc; do
    echo "Deleting VPC $vpc"
    aws ec2 delete-vpc --vpc-id "$vpc" --region $REGION || true
done

echo "✅ AWS account CLEANED SUCCESSFULLY"
