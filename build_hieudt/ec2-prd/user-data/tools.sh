#!/bin/bash
set -e

apt update -y
curl -fsSL https://get.docker.com | bash
systemctl enable docker
systemctl start docker

docker run -d \
  --name jenkins \
  -p 8080:8080 \
  jenkins/jenkins:lts
