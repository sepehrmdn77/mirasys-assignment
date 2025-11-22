#!/usr/bin/env bash

sudo hostnamectl set-hostname worker-1
sudo swapoff -a
vi /etc/fstab

sudo apt-get update -y
sudo apt-get install -y curl

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

sudo apt-get install -y containerd git-all

sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/            SystemdCgroup = false/            SystemdCgroup = true/' /etc/containerd/config.toml

echo '================================= Healthcheck ================================='
grep 'SystemdCgroup = true' /etc/containerd/config.toml
sleep 3

sudo systemctl restart containerd

sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
apt-cache policy kubelet | head -n 20

sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl containerd

echo '================================= Healthcheck ================================='
sudo systemctl start kubelet.service
sudo systemctl status kubelet.service
sudo systemctl status containerd.service
sudo modprobe br_netfilter
sudo modprobe overlay
sudo sysctl --system

echo "Worker-node-1 is ready, run <sudo kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>> to join the master-node"
sleep 5
