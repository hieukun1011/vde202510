#!/bin/bash
set -e

KEY_NAME="mykey"
SG_NAME="my-sg"
INSTANCE_TYPE="t2.micro"
AMI_ID="ami-0c02fb55956c7d316"

echo "🔍 Checking AWS auth..."
aws sts get-caller-identity > /dev/null

# =====================
# KEY PAIR
# =====================
if ! aws ec2 describe-key-pairs --key-names "$KEY_NAME" >/dev/null 2>&1; then
  aws ec2 create-key-pair \
    --key-name "$KEY_NAME" \
    --query "KeyMaterial" \
    --output text > "$KEY_NAME.pem"
  chmod 400 "$KEY_NAME.pem"
fi

# =====================
# SECURITY GROUP
# =====================
if aws ec2 describe-security-groups --group-names "$SG_NAME" >/dev/null 2>&1; then
  SG_ID=$(aws ec2 describe-security-groups \
    --group-names "$SG_NAME" \
    --query "SecurityGroups[0].GroupId" \
    --output text)
else
  SG_ID=$(aws ec2 create-security-group \
    --group-name "$SG_NAME" \
    --description "Allow SSH + HTTP" \
    --query "GroupId" \
    --output text)

  aws ec2 authorize-security-group-ingress \
    --group-id "$SG_ID" \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0

  aws ec2 authorize-security-group-ingress \
    --group-id "$SG_ID" \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0
fi

# =====================
# CREATE EC2 WITH USER DATA
# =====================
echo "🚀 Creating EC2 with Docker pre-installed..."

INSTANCE_ID=$(aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --instance-type "$INSTANCE_TYPE" \
  --key-name "$KEY_NAME" \
  --security-group-ids "$SG_ID" \
  --user-data file://$(dirname "$0")/user_data.sh \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=auto-docker-ec2}]' \
  --query "Instances[0].InstanceId" \
  --output text)

aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text)

echo "=============================="
echo "✅ EC2 READY"
echo "Instance ID : $INSTANCE_ID"
echo "Public IP   : $PUBLIC_IP"
echo "Docker is already installed"
echo "=============================="
