#!/bin/bash
set -e

LOG="/var/log/user-data.log"
echo "🚀 ODOO USER-DATA START" | tee -a $LOG

# =====================
# SYSTEM UPDATE
# =====================
yum update -y >> $LOG

# =====================
# INSTALL DOCKER
# =====================
amazon-linux-extras install docker -y >> $LOG
systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user

# =====================
# INSTALL DOCKER COMPOSE v2
# =====================
COMPOSE_VERSION="v2.27.0"
mkdir -p /usr/local/lib/docker/cli-plugins

curl -SL https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose

chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# =====================
# CREATE ODOO STRUCTURE
# =====================
mkdir -p /opt/odoo/{addons,config,data}
chown -R ec2-user:ec2-user /opt/odoo

# =====================
# CREATE docker-compose.yml
# =====================
cat <<EOF > /opt/odoo/docker-compose.yml
services:
  odoo:
    image: odoo:18
    container_name: odoo_demo_vde
    ports:
      - "8069:8069"
    volumes:
      - ./config:/etc/odoo
      - ./data:/var/lib/odoo
    environment:
      - HOST=<private-ip-postgres>
      - USER=odoo
      - PASSWORD=odoo
    restart: always
EOF

# =====================
# START ODOO
# =====================
cd /opt/odoo
/usr/local/lib/docker/cli-plugins/docker-compose up -d >> $LOG

echo "✅ ODOO DEPLOYED" | tee -a $LOG
