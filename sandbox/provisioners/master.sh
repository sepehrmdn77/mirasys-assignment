#!/bin/bash

sudo hostnamectl set-hostname master-node
sudo swapoff -a
vi /etc/fstab

sudo apt-get update -y
sudo apt-get install -y curl apt-transport-https

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

echo '================================= Healthcheck ================================='
ls /proc/sys/net/bridge/

sudo mkdir -p /etc/systemd/system/kubelet.service.d
echo -e "[Service]\nEnvironment=\"KUBELET_EXTRA_ARGS=--node-ip=192.168.56.10\"" | sudo tee /etc/systemd/system/kubelet.service.d/10-node-ip.conf
echo 'KUBELET_KUBEADM_ARGS="--container-runtime-endpoint=unix:///var/run/containerd/containerd.sock --pod-infra-container-image=registry.k8s.io/pause:3.9 --node-ip=192.168.56.10"' | sudo tee /var/lib/kubelet/kubeadm-flags.env
sudo systemctl daemon-reexec
sudo systemctl restart kubelet



sudo kubeadm reset -f
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.56.10 | tee init-output.txt
echo '============================ Save the token command ============================'
sleep 5

rm -rf ~/.kube
sudo mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
kubectl -n kube-flannel rollout status daemonset/kube-flannel-ds --timeout=2m
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
curl -s https://fluxcd.io/install.sh | sudo bash
flux install --components=image-reflector-controller,image-automation-controller

echo '================================= Healthcheck =================================' 
helm version
flux --version
sleep 3

echo "Cluster initialized, you can now join workers."
sleep 5
