#!/bin/bash
set -e
source ./00-env.sh
source .env

echo "🚀 Creating Odoo EC2..."

USER_DATA=$(cat <<EOF
#!/bin/bash
set -e

DB_HOST=${POSTGRES_PRIVATE_IP}

apt update -y
curl -fsSL https://get.docker.com | bash
systemctl enable docker
systemctl start docker

curl -L https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-linux-x86_64 \
  -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

mkdir -p /opt/odoo
cd /opt/odoo

cat > docker-compose.yml <<EOC
version: "3.8"
services:
  odoo:
    image: odoo:17
    restart: always
    ports:
      - "8069:8069"
    environment:
      - HOST=\${DB_HOST}
      - USER=odoo
      - PASSWORD=odoo123
    volumes:
      - odoo-data:/var/lib/odoo
volumes:
  odoo-data:
EOC

# Đợi PostgreSQL sẵn sàng
sleep 30

docker compose up -d
EOF
)

INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_NAME \
  --subnet-id $PUBLIC_SUBNET_ID \
  --security-group-ids $SG_ODDO \
  --user-data "$USER_DATA" \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=odoo-app}]' \
  --query 'Instances[0].InstanceId' \
  --output text)

aws ec2 wait instance-running --instance-ids $INSTANCE_ID

PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

echo "ODDO_PUBLIC_IP=$PUBLIC_IP" >> .env

echo "✅ Odoo EC2 ready"
echo "🌍 URL: http://$PUBLIC_IP:8069"
