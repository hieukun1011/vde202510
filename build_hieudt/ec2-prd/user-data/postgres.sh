#!/bin/bash
set -e

apt update -y
apt install -y postgresql

sudo -u postgres psql <<EOF
CREATE DATABASE odoo;
CREATE USER odoo WITH PASSWORD 'odoo123';
GRANT ALL PRIVILEGES ON DATABASE odoo TO odoo;
EOF

sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/*/main/postgresql.conf
echo "host all all 10.0.0.0/16 md5" >> /etc/postgresql/*/main/pg_hba.conf

systemctl restart postgresql
systemctl enable postgresql
