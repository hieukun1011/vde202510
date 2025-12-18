#!/bin/bash
set -e

LOG_FILE="/var/log/user-data.log"

echo "🚀 User data started" | tee -a $LOG_FILE

# =====================
# UPDATE SYSTEM
# =====================
yum update -y >> $LOG_FILE

# =====================
# INSTALL DOCKER
# =====================
amazon-linux-extras install docker -y >> $LOG_FILE

systemctl start docker
systemctl enable docker

# =====================
# ADD ec2-user to docker group
# =====================
usermod -aG docker ec2-user

# =====================
# INSTALL DOCKER COMPOSE v2
# =====================
COMPOSE_VERSION="v2.27.0"
mkdir -p /usr/local/lib/docker/cli-plugins

curl -SL \
https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-x86_64 \
-o /usr/local/lib/docker/cli-plugins/docker-compose

chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# =====================
# TEST
# =====================
docker --version >> $LOG_FILE
docker compose version >> $LOG_FILE

echo "✅ Docker & Docker Compose installed" | tee -a $LOG_FILE
