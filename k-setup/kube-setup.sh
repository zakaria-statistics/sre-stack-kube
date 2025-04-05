#!/bin/bash
#
# Reset and Setup for Control Plane (Master) servers

set -euxo pipefail

# Reset Kubernetes cluster with CRI-O socket
# sudo kubeadm reset -f --cri-socket=/var/run/crio/crio.sock
# sudo rm -rf /etc/cni/net.d
# sudo rm -rf $HOME/.kube
# sudo systemctl restart crio kubelet

# If you need public access to API server using the servers Public IP address, change PUBLIC_IP_ACCESS to true.

PUBLIC_IP_ACCESS="false"
NODENAME=$(hostname -s)
POD_CIDR="192.168.0.0/16"

# Pull required images
sudo kubeadm config images pull --cri-socket=/var/run/crio/crio.sock

# Initialize kubeadm based on PUBLIC_IP_ACCESS

if [[ "$PUBLIC_IP_ACCESS" == "false" ]]; then

    MASTER_PRIVATE_IP=$(ip addr show enp0s8 | awk '/inet / {print $2}' | cut -d/ -f1)
    sudo kubeadm init --apiserver-advertise-address="$MASTER_PRIVATE_IP" --apiserver-cert-extra-sans="$MASTER_PRIVATE_IP" --pod-network-cidr="$POD_CIDR" --node-name "$NODENAME" --ignore-preflight-errors Swap --cri-socket=/var/run/crio/crio.sock

elif [[ "$PUBLIC_IP_ACCESS" == "true" ]]; then

    MASTER_PUBLIC_IP=$(curl ifconfig.me && echo "")
    sudo kubeadm init --control-plane-endpoint="$MASTER_PUBLIC_IP" --apiserver-cert-extra-sans="$MASTER_PUBLIC_IP" --pod-network-cidr="$POD_CIDR" --node-name "$NODENAME" --ignore-preflight-errors Swap --cri-socket=/var/run/crio/crio.sock

else
    echo "Error: MASTER_PUBLIC_IP has an invalid value: $PUBLIC_IP_ACCESS"
    exit 1
fi

# Configure kubeconfig
mkdir -p "$HOME"/.kube
sudo cp -i /etc/kubernetes/admin.conf "$HOME"/.kube/config
sudo chown "$(id -u)":"$(id -g)" "$HOME"/.kube/config
kubectl taint nodes kube node-role.kubernetes.io/control-plane:NoSchedule-
# Install Calico Network Plugin
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

