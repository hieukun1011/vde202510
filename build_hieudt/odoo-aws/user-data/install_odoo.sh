docker run -d \
  -p 8069:8069 \
  --name odoo \
  -e HOST=<PRIVATE_IP_POSTGRES> \
  -e USER=odoo \
  -e PASSWORD=odoo_strong_password \
  odoo:17
