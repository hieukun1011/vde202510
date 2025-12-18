#!/bin/bash
set -e

echo "=== Install PostgreSQL 15 ==="

# Enable PostgreSQL repo
amazon-linux-extras enable postgresql15
yum clean metadata
yum install -y postgresql15 postgresql15-server

# Init DB
/usr/bin/postgresql-15-setup initdb

# Start & enable
systemctl start postgresql
systemctl enable postgresql

echo "PostgreSQL installed & running"
