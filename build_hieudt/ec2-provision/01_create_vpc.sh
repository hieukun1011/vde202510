#!/bin/bash
set -e

REGION=$(aws configure get region)
VPC_CIDR="10.0.0.0/16"
PUBLIC_SUBNET_CIDR="10.0.1.0/24"
PRIVATE_SUBNET_CIDR="10.0.2.0/24"

echo "🚀 Creating VPC..."

VPC_ID=$(aws ec2 create-vpc \
  --cidr-block $VPC_CIDR \
  --query "Vpc.VpcId" \
  --output text)

aws ec2 create-tags --resources $VPC_ID --tags Key=Name,Value=odoo-vpc
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-support
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames

echo "✅ VPC: $VPC_ID"

# =====================
# SUBNETS
# =====================
PUBLIC_SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $PUBLIC_SUBNET_CIDR \
  --query "Subnet.SubnetId" \
  --output text)

PRIVATE_SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $PRIVATE_SUBNET_CIDR \
  --query "Subnet.SubnetId" \
  --output text)

aws ec2 create-tags --resources $PUBLIC_SUBNET_ID --tags Key=Name,Value=public-subnet
aws ec2 create-tags --resources $PRIVATE_SUBNET_ID --tags Key=Name,Value=private-subnet

# =====================
# INTERNET GATEWAY
# =====================
IGW_ID=$(aws ec2 create-internet-gateway \
  --query "InternetGateway.InternetGatewayId" \
  --output text)

aws ec2 attach-internet-gateway \
  --internet-gateway-id $IGW_ID \
  --vpc-id $VPC_ID

# =====================
# ROUTE TABLE PUBLIC
# =====================
PUBLIC_RT_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --query "RouteTable.RouteTableId" \
  --output text)

aws ec2 create-route \
  --route-table-id $PUBLIC_RT_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW_ID

aws ec2 associate-route-table \
  --subnet-id $PUBLIC_SUBNET_ID \
  --route-table-id $PUBLIC_RT_ID

echo "🎉 VPC setup completed"
echo "VPC=$VPC_ID"
echo "PUBLIC_SUBNET=$PUBLIC_SUBNET_ID"
echo "PRIVATE_SUBNET=$PRIVATE_SUBNET_ID"
