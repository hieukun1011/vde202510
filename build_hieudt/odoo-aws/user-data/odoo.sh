#!/bin/bash
set -e

POSTGRES_HOST="10.0.2.214"   # 🔴 IP PRIVATE CỦA POSTGRES EC2

echo "🚀 Installing Docker for Odoo..."

apt update -y
apt install -y ca-certificates curl gnupg lsb-release

curl -fsSL https://get.docker.com | sh
usermod -aG docker ubuntu

systemctl enable docker
systemctl start docker

mkdir -p /opt/odoo
cd /opt/odoo

cat <<EOF > odoo.conf
[options]
admin_passwd = admin
db_host = ${POSTGRES_HOST}
db_port = 5432
db_user = odoo
db_password = odoo
addons_path = /mnt/extra-addons
logfile = /var/log/odoo/odoo.log
proxy_mode = True
EOF

cat <<EOF > docker-compose.yml
version: "3.8"

services:
  odoo:
    image: odoo:17
    container_name: odoo
    restart: always
    ports:
      - "8069:8069"
    volumes:
      - odoo-data:/var/lib/odoo
      - ./odoo.conf:/etc/odoo/odoo.conf
    command: ["odoo", "-c", "/etc/odoo/odoo.conf"]
EOF

echo "volumes:
  odoo-data:" >> docker-compose.yml

docker compose up -d

echo "⏳ Waiting for Odoo..."
sleep 20

echo "✅ Odoo is running on port 8069"
