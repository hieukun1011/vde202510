#!/bin/bash
set -e

DB_HOST=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/ | head -n1)

apt update -y
curl -fsSL https://get.docker.com | bash
systemctl enable docker
systemctl start docker

curl -L https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-linux-x86_64 \
  -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

mkdir -p /opt/odoo
cd /opt/odoo

cat > docker-compose.yml <<EOF
version: "3.8"
services:
  odoo:
    image: odoo:17
    restart: always
    ports:
      - "8069:8069"
    environment:
      - HOST=${POSTGRES_PRIVATE_IP}
      - USER=odoo
      - PASSWORD=odoo123
    volumes:
      - odoo-data:/var/lib/odoo
volumes:
  odoo-data:
EOF

docker-compose up -d
