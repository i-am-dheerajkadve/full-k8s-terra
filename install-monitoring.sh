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
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
helm repo update

echo "Creating monitoring namespace..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

echo "Installing Prometheus and Grafana..."
helm upgrade --install $RELEASE_NAME prometheus-community/kube-prometheus-stack \
  --namespace $NAMESPACE \
  --wait \
  --timeout 10m

echo "Checking pods..."
kubectl get pods -n $NAMESPACE

echo "Getting Grafana admin password..."
echo "Username: admin"
echo -n "Password: "
kubectl get secret ${RELEASE_NAME}-grafana -n $NAMESPACE \
  -o jsonpath="{.data.admin-password}" | base64 --decode
echo ""

echo "Services:"
kubectl get svc -n $NAMESPACE

echo "Installation completed successfully."
echo "To access Grafana locally, run:"
echo "kubectl port-forward svc/${RELEASE_NAME}-grafana -n $NAMESPACE $GRAFANA_PORT:80"

echo "To access Prometheus locally, run:"
echo "kubectl port-forward svc/${RELEASE_NAME}-kube-prome-prometheus -n $NAMESPACE $PROMETHEUS_PORT:9090"


# to install argocd into the eks
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl get pods -n argocd
kubectl port-forward svc/argocd-server -n argocd 8080:443

echo -n "Password: "
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
echo ""
