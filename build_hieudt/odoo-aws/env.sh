#!/bin/bash
set -e

export REGION="us-east-1"
export AZ="us-east-1a"

export VPC_CIDR="10.0.0.0/16"
export PUBLIC_SUBNET_CIDR="10.0.1.0/24"
export PRIVATE_SUBNET_CIDR="10.0.2.0/24"

export KEY_NAME="mykey"
export AMI_ID="ami-0fc5d935ebf8bc3bc"   # Ubuntu 22.04 us-east-1
export INSTANCE_TYPE="t3.medium"

export PROJECT="odoo-prd"
