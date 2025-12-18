#!/bin/bash
set -e

ODOO_DB_USER="odoo"
ODOO_DB_PASS="odoo_strong_password"

sudo -u postgres psql <<EOF
-- Create user
CREATE USER $ODOO_DB_USER WITH PASSWORD '$ODOO_DB_PASS';

-- Allow create DB (Odoo needs this)
ALTER USER $ODOO_DB_USER CREATEDB;

-- Security hardening
REVOKE ALL ON SCHEMA public FROM public;
EOF

echo "Odoo DB user created"
