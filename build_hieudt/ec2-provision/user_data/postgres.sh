#!/bin/bash
set -e

echo "🚀 Installing PostgreSQL..."

apt update -y
apt install -y postgresql postgresql-contrib

sudo -u postgres psql <<EOF
CREATE DATABASE odoo;
CREATE USER odoo WITH PASSWORD 'odoo123';
ALTER ROLE odoo SET client_encoding TO 'utf8';
ALTER ROLE odoo SET default_transaction_isolation TO 'read committed';
ALTER ROLE odoo SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE odoo TO odoo;
EOF

# Allow private subnet access
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/*/main/postgresql.conf

cat >> /etc/postgresql/*/main/pg_hba.conf <<EOF
host    all             all             10.0.0.0/16            md5
EOF

systemctl restart postgresql
systemctl enable postgresql

echo "✅ PostgreSQL ready"
