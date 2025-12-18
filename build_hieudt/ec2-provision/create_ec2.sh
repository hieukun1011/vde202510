#!/bin/bash
set -e

# =====================
# CONFIG
# =====================
KEY_NAME="mykey"
SG_NAME="my-sg"
INSTANCE_TYPE="t2.micro"
AMI_ID="ami-0c02fb55956c7d316"   # Amazon Linux 2
REGION=$(aws configure get region)

# =====================
# CHECK AWS LOGIN
# =====================
echo "🔍 Checking AWS credentials..."
aws sts get-caller-identity > /dev/null
echo "✅ AWS CLI authenticated"

# =====================
# CREATE KEY PAIR
# =====================
if aws ec2 describe-key-pairs --key-names "$KEY_NAME" >/dev/null 2>&1; then
  echo "🔑 Key pair '$KEY_NAME' already exists"
else
  echo "🔑 Creating key pair..."
  aws ec2 create-key-pair \
    --key-name "$KEY_NAME" \
    --query "KeyMaterial" \
    --output text > "$KEY_NAME.pem"
  chmod 400 "$KEY_NAME.pem"
  echo "✅ Key pair created: $KEY_NAME.pem"
fi

# =====================
# CREATE SECURITY GROUP
# =====================
if aws ec2 describe-security-groups --group-names "$SG_NAME" >/dev/null 2>&1; then
  echo "🛡 Security group '$SG_NAME' already exists"
  SG_ID=$(aws ec2 describe-security-groups \
    --group-names "$SG_NAME" \
    --query "SecurityGroups[0].GroupId" \
    --output text)
else
  echo "🛡 Creating security group..."
  SG_ID=$(aws ec2 create-security-group \
    --group-name "$SG_NAME" \
    --description "Allow SSH" \
    --query "GroupId" \
    --output text)

  aws ec2 authorize-security-group-ingress \
    --group-id "$SG_ID" \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0

  echo "✅ Security group created: $SG_ID"
fi

# =====================
# CREATE EC2
# =====================
echo "🚀 Launching EC2 instance..."

INSTANCE_ID=$(aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --instance-type "$INSTANCE_TYPE" \
  --key-name "$KEY_NAME" \
  --security-group-ids "$SG_ID" \
  --query "Instances[0].InstanceId" \
  --output text)

echo "⏳ Waiting for instance to be running..."
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text)

echo "=============================="
echo "✅ EC2 CREATED SUCCESSFULLY"
echo "Instance ID : $INSTANCE_ID"
echo "Public IP   : $PUBLIC_IP"
echo "SSH command : ssh -i $KEY_NAME.pem ec2-user@$PUBLIC_IP"
echo "=============================="
