#!/bin/bash
set -e

echo "🚀 Installing Docker & PostgreSQL..."

# Update
apt update -y

# Install Docker + compose plugin
apt install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  docker.io \
  docker-compose-plugin

systemctl enable docker
systemctl start docker

# Add ubuntu to docker group (cho login sau)
usermod -aG docker ubuntu

# Prepare folder
mkdir -p /opt/postgres
cd /opt/postgres

# Create docker-compose.yml
cat <<'EOF' > docker-compose.yml
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

volumes:
  pgdata:
EOF

# Start PostgreSQL
docker compose up -d

echo "✅ PostgreSQL container started"
