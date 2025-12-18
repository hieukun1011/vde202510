#!/bin/bash
set -e

echo "🚀 Installing Docker for PostgreSQL..."

apt update -y
apt install -y ca-certificates curl gnupg lsb-release

curl -fsSL https://get.docker.com | sh
usermod -aG docker ubuntu

systemctl enable docker
systemctl start docker

mkdir -p /opt/postgres
cd /opt/postgres

cat <<EOF > docker-compose.yml
version: "3.8"

services:
  postgres:
    image: postgres:15
    container_name: postgres
    restart: always
    environment:
      POSTGRES_DB: odoo
      POSTGRES_USER: odoo
      POSTGRES_PASSWORD: odoo
    volumes:
      - pgdata:/var/lib/postgresql/data
    ports:
      - "5432:5432"
EOF

echo "volumes:
  pgdata:" >> docker-compose.yml

docker compose up -d

echo "✅ PostgreSQL is running"
