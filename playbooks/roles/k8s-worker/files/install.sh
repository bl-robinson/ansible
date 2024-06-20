#!/bin/bash
echo "INFO: Installing common ...."
apt-get update
apt-get install -y \
    gnupg2 \
    software-properties-common \
    nfs-common \
    dnsutils \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    containerd

cat <<EOT > /etc/containerd/config.toml
version = 2
[plugins]
    [plugins."io.containerd.grpc.v1.cri"]
    [plugins."io.containerd.grpc.v1.cri".containerd]
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
            runtime_type = "io.containerd.runc.v2"
            [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
            SystemdCgroup = true
EOT
systemctl restart containerd

echo "INFO: Common installed."

echo "INFO: Mounting k8s share"
echo '${nfs_server_ip}:/mnt/k8s /mnt/k8s nfs4 defaults 0 0' >> /etc/fstab
mkdir /mnt/k8s
mount /mnt/k8s

echo "INFO: Doing k8s prereq..."
cat <<EOF | tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system
echo "INFO: Installing K8..."
mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
chmod 644 /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet=1.30.0-1.1 kubeadm=1.30.0-1.1 kubectl=1.30.0-1.1
apt-mark hold kubelet kubeadm kubectl
echo "INFO: Done Installing K8s"

echo "INFO: Init Worker Node"
echo "INFO: Waiting for files to exist"
while [ ! -f /mnt/k8s/token ]; do sleep 1; done
while [ ! -f /mnt/k8s/ca-cert-hash ]; do sleep 1; done

echo "INFO: Join Cluster"
kubeadm join --token "$(cat /mnt/k8s/token)" 10.0.0.20:6443 --discovery-token-ca-cert-hash sha256:"$(cat /mnt/k8s/ca-cert-hash)"
touch /mnt/k8s/worker-complete-${count}
echo "INFO: Check if we need to remove the join token"
if [[ "$(ls /mnt/k8s | grep worker-complete | wc -l)" -eq ${worker_count} ]]
then
    echo "INFO: Remove used k8s join token"
    rm /mnt/k8s/token
    rm /mnt/k8s/ca-cert-hash
    rm /mnt/k8s/worker-complete-*
fi

echo "10.0.0.100 container-registry.k8s.home.blrobinson.uk." >> /etc/hosts
