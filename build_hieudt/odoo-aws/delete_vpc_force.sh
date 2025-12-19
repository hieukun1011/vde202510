#!/bin/bash
set -e

REGION=us-east-1
VPC_ID=$1

if [ -z "$VPC_ID" ]; then
  echo "Usage: ./delete_vpc_force.sh vpc-xxxxxxxx"
  exit 1
fi

echo "🔥 FORCE DELETE VPC: $VPC_ID"

# 1. Terminate EC2
echo "👉 Terminating EC2 instances..."
INSTANCES=$(aws ec2 describe-instances \
  --filters Name=vpc-id,Values=$VPC_ID \
  --query "Reservations[].Instances[].InstanceId" \
  --output text \
  --region $REGION)

if [ -n "$INSTANCES" ]; then
  aws ec2 terminate-instances --instance-ids $INSTANCES --region $REGION
  aws ec2 wait instance-terminated --instance-ids $INSTANCES --region $REGION
fi

# 2. Delete Load Balancers
echo "👉 Deleting Load Balancers..."
LBS=$(aws elbv2 describe-load-balancers \
  --query "LoadBalancers[?VpcId=='$VPC_ID'].LoadBalancerArn" \
  --output text \
  --region $REGION)

for lb in $LBS; do
  aws elbv2 delete-load-balancer --load-balancer-arn $lb --region $REGION
done

# 3. Delete NAT Gateways
echo "👉 Deleting NAT Gateways..."
NATS=$(aws ec2 describe-nat-gateways \
  --filter Name=vpc-id,Values=$VPC_ID \
  --query "NatGateways[].NatGatewayId" \
  --output text \
  --region $REGION)

for nat in $NATS; do
  aws ec2 delete-nat-gateway --nat-gateway-id $nat --region $REGION
done

sleep 60

# 4. Detach & delete IGW
echo "👉 Deleting Internet Gateway..."
IGW=$(aws ec2 describe-internet-gateways \
  --filters Name=attachment.vpc-id,Values=$VPC_ID \
  --query "InternetGateways[].InternetGatewayId" \
  --output text \
  --region $REGION)

for igw in $IGW; do
  aws ec2 detach-internet-gateway --internet-gateway-id $igw --vpc-id $VPC_ID --region $REGION
  aws ec2 delete-internet-gateway --internet-gateway-id $igw --region $REGION
done

# 5. Delete VPC Endpoints
echo "👉 Deleting VPC Endpoints..."
ENDPOINTS=$(aws ec2 describe-vpc-endpoints \
  --filters Name=vpc-id,Values=$VPC_ID \
  --query "VpcEndpoints[].VpcEndpointId" \
  --output text \
  --region $REGION)

for ep in $ENDPOINTS; do
  aws ec2 delete-vpc-endpoints --vpc-endpoint-ids $ep --region $REGION
done

# 6. Delete ENI (QUAN TRỌNG)
echo "👉 Deleting Network Interfaces..."
ENIS=$(aws ec2 describe-network-interfaces \
  --filters Name=vpc-id,Values=$VPC_ID \
  --query "NetworkInterfaces[].NetworkInterfaceId" \
  --output text \
  --region $REGION)

for eni in $ENIS; do
  aws ec2 delete-network-interface --network-interface-id $eni --region $REGION || true
done

# 7. Delete Subnets
echo "👉 Deleting Subnets..."
SUBNETS=$(aws ec2 describe-subnets \
  --filters Name=vpc-id,Values=$VPC_ID \
  --query "Subnets[].SubnetId" \
  --output text \
  --region $REGION)

for subnet in $SUBNETS; do
  aws ec2 delete-subnet --subnet-id $subnet --region $REGION
done

# 8. Delete Route Tables (non-main)
echo "👉 Deleting Route Tables..."
RTS=$(aws ec2 describe-route-tables \
  --filters Name=vpc-id,Values=$VPC_ID \
  --query "RouteTables[?Associations[0].Main==\`false\`].RouteTableId" \
  --output text \
  --region $REGION)

for rt in $RTS; do
  aws ec2 delete-route-table --route-table-id $rt --region $REGION
done

# 9. Delete Security Groups (non-default)
echo "👉 Deleting Security Groups..."
SGS=$(aws ec2 describe-security-groups \
  --filters Name=vpc-id,Values=$VPC_ID \
  --query "SecurityGroups[?GroupName!='default'].GroupId" \
  --output text \
  --region $REGION)

for sg in $SGS; do
  aws ec2 delete-security-group --group-id $sg --region $REGION
done

# 10. Delete VPC
echo "🔥 Deleting VPC..."
aws ec2 delete-vpc --vpc-id $VPC_ID --region $REGION

echo "✅ VPC $VPC_ID DELETED SUCCESSFULLY"
