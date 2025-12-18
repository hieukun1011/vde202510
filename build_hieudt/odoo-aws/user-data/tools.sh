#!/bin/bash
set -e

echo "🚀 Installing Docker for Tools..."

apt update -y
apt install -y ca-certificates curl gnupg lsb-release

curl -fsSL https://get.docker.com | sh
usermod -aG docker ubuntu

systemctl enable docker
systemctl start docker

mkdir -p /opt/tools
cd /opt/tools

cat <<EOF > docker-compose.yml
version: "3.8"

services:
  jenkins:
    image: jenkins/jenkins:lts
    container_name: jenkins
    ports:
      - "8080:8080"
    volumes:
      - jenkins-data:/var/jenkins_home
    restart: always

  grafana:
    image: grafana/grafana
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana-data:/var/lib/grafana
    restart: always

  prometheus:
    image: prom/prometheus
    container_name: prometheus
    ports:
      - "9090:9090"
    restart: always

  loki:
    image: grafana/loki
    container_name: loki
    ports:
      - "3100:3100"
    restart: always
EOF

echo "volumes:
  jenkins-data:
  grafana-data:" >> docker-compose.yml

docker compose up -d

echo "✅ Tools stack ready"
