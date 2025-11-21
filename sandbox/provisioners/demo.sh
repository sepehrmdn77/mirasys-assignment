#!/bin/bash

sudo hostnamectl set-hostname demo

sudo apt-get update -y
sudo apt-get install -y curl gnupg lsb-release

sudo mkdir -p /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker vagrant

sudo systemctl start docker
sudo systemctl enable docker

echo "✅ Provisioning completed successfully!"
echo "🐍 Python virtual environment: /home/vagrant/devsepops/venv"
echo "🐳 Docker installed and configured"
