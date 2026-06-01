#!/bin/bash
set -e

NAMESPACE="monitoring"
RELEASE_NAME="kube-prometheus"
GRAFANA_PORT="3001"
PROMETHEUS_PORT="9090"

echo "Checking kubectl connection..."
kubectl cluster-info

echo "Installing Helm if not installed..."
if ! command -v helm &> /dev/null; then
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
else
  echo "Helm already installed"
fi

helm version

echo "Adding Prometheus Helm repo..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

echo "Creating monitoring namespace..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

echo "Installing Prometheus and Grafana..."
helm upgrade --install $RELEASE_NAME prometheus-community/kube-prometheus-stack \
  --namespace $NAMESPACE

echo "Waiting for pods to be ready..."
kubectl wait --for=condition=Ready pods --all -n $NAMESPACE --timeout=300s

echo "Getting Grafana admin password..."
echo "Username: admin"
echo -n "Password: "
kubectl get secret ${RELEASE_NAME}-grafana -n $NAMESPACE \
  -o jsonpath="{.data.admin-password}" | base64 --decode
echo ""

echo "Starting port forwarding..."
echo "Grafana:    http://localhost:$GRAFANA_PORT"
echo "Prometheus: http://localhost:$PROMETHEUS_PORT"
echo "Press CTRL+C to stop port forwarding"

kubectl port-forward svc/${RELEASE_NAME}-grafana -n $NAMESPACE $GRAFANA_PORT:80 &
kubectl port-forward svc/${RELEASE_NAME}-kube-prometheus-prometheus -n $NAMESPACE $PROMETHEUS_PORT:9090 &

wait
