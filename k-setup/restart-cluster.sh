#!/bin/bash
# start-kubeadm-cluster.sh - Script to start a kubeadm Kubernetes cluster after VM restart

echo "Starting Kubernetes cluster restoration procedure..."

# If this is running on the actual nodes
if command -v systemctl &> /dev/null; then
  echo "Checking kubelet service status"
  if ! systemctl is-active --quiet kubelet; then
    echo "Starting kubelet service"
    sudo systemctl start kubelet
  else
    echo "kubelet service is already running"
  fi
else
  echo "IMPORTANT: Ensure kubelet service is running on each node."
  echo "Run the following command on each node if needed:"
  echo "sudo systemctl start kubelet"
fi

# Wait for API server to become available
echo "Waiting for Kubernetes API server to become available..."
until kubectl get nodes &>/dev/null
do
  echo "Waiting for API server..."
  sleep 5
done

# Uncordon the specific node "kube"
echo "Uncordoning node: kube"
kubectl uncordon kube

# Check cluster health
echo "Checking cluster health..."
echo "Node status:"
kubectl get nodes
echo "Pod status:"
kubectl get pods -A | grep -v Running | grep -v Completed

echo "Kubernetes cluster should now be operational."
echo "If any pods are in error state, you may need to restart them manually."
