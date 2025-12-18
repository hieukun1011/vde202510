#!/bin/bash
set -e

LOG="/var/log/user-data.log"
echo "🚀 TOOLS USER-DATA START" | tee -a $LOG

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
# INSTALL DOCKER COMPOSE
# =====================
COMPOSE_VERSION="v2.27.0"
mkdir -p /usr/local/lib/docker/cli-plugins

curl -SL https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose

chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# =====================
# CREATE TOOLS STRUCTURE
# =====================
mkdir -p /opt/tools/{jenkins,grafana,prometheus,loki}
chown -R ec2-user:ec2-user /opt/tools

# =====================
# PROMETHEUS CONFIG
# =====================
cat <<EOF > /opt/tools/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'odoo'
    static_configs:
      - targets: ['odoo-app:8069']
EOF

# =====================
# DOCKER COMPOSE
# =====================
cat <<EOF > /opt/tools/docker-compose.yml
services:
  jenkins:
    image: jenkins/jenkins:lts
    ports:
      - "8080:8080"
    volumes:
      - ./jenkins:/var/jenkins_home

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    volumes:
      - ./grafana:/var/lib/grafana

  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml

  loki:
    image: grafana/loki
    ports:
      - "3100:3100"
EOF

# =====================
# START TOOLS
# =====================
cd /opt/tools
/usr/local/lib/docker/cli-plugins/docker-compose up -d >> $LOG

echo "✅ DEVOPS TOOLS DEPLOYED" | tee -a $LOG
