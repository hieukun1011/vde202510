#!/bin/bash
set -e

PG_CONF="/var/lib/pgsql/15/data/postgresql.conf"
PG_HBA="/var/lib/pgsql/15/data/pg_hba.conf"

echo "=== Configure PostgreSQL for Odoo ==="

# Backup
cp $PG_CONF ${PG_CONF}.bak
cp $PG_HBA ${PG_HBA}.bak

# Listen all (private subnet)
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" $PG_CONF

# Optimize for Odoo (EC2 t3.micro/t3.small)
cat <<EOF >> $PG_CONF

# Odoo tuning
shared_buffers = 256MB
work_mem = 16MB
maintenance_work_mem = 64MB
effective_cache_size = 512MB
max_connections = 100
EOF

# Allow Odoo server access (change CIDR if needed)
cat <<EOF >> $PG_HBA

# Odoo access
host    all     odoo    10.0.1.0/24    md5
EOF

# Restart PostgreSQL
systemctl restart postgresql

echo "PostgreSQL configured for Odoo"
