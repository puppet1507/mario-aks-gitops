# Mario AKS GitOps - Quick Setup

## Install Tools
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Terraform
sudo apt install wget unzip -y
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# ArgoCD CLI
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
```

## Clone Repository
```bash
# Clone project về máy
cd ~
git clone https://github.com/puppet1507/mario-aks-gitops.git
cd mario-aks-gitops
```

## Azure Login
```bash
# Login vào Azure
az login

# Set subscription (thay <your-subscription-id> bằng subscription ID của bạn)
az account set --subscription "<your-subscription-id>"
```

## Deploy DEV
```bash
# Vào thư mục terraform dev
cd ~/mario-aks-gitops/terraform/environments/dev

# Khởi tạo Terraform
terraform init

# Deploy infrastructure (AKS cluster, networking, etc.)
terraform apply -auto-approve

# Kết nối kubectl với AKS cluster dev
az aks get-credentials --resource-group mario-dev-rg --name mario-aks-dev --overwrite-existing

# Tạo namespace cho ArgoCD
kubectl create namespace argocd

# Cài đặt ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Lấy password ArgoCD (username: admin)
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Mở ArgoCD UI (truy cập https://<your-vm-ip>:8080)
kubectl port-forward svc/argocd-server -n argocd 8080:443 --address 0.0.0.0

# Deploy ứng dụng Mario qua ArgoCD
cd ~/mario-aks-gitops
kubectl apply -f argocd/mario-frontend-dev.yaml
kubectl apply -f argocd/mario-backend-dev.yaml
```

## Deploy PROD
```bash
# Vào thư mục terraform prod
cd ~/mario-aks-gitops/terraform/environments/prod

# Khởi tạo Terraform
terraform init

# Deploy infrastructure production
terraform apply -auto-approve

# Kết nối kubectl với AKS cluster prod
az aks get-credentials --resource-group mario-prod-rg --name mario-aks-prod --overwrite-existing

# Tạo namespace cho ArgoCD
kubectl create namespace argocd

# Cài đặt ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Lấy password ArgoCD (username: admin)
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Mở ArgoCD UI (truy cập https://<your-vm-ip>:8080)
kubectl port-forward svc/argocd-server -n argocd 8080:443 --address 0.0.0.0

# Mở nginx ingress để truy cập app (http://<your-vm-ip>:8081)
kubectl port-forward svc/nginx-ingress-ingress-nginx-controller 8081:80 -n ingress-nginx

# Deploy ứng dụng Mario qua ArgoCD
cd ~/mario-aks-gitops
kubectl apply -f argocd/mario-frontend-prod.yaml
kubectl apply -f argocd/mario-backend-prod.yaml
kubectl apply -f argocd/argo-ingress-prod.yaml
```

## Optional: Monitoring Stack
```bash
# Thêm Helm repo Prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Tạo namespace monitoring
kubectl create namespace monitoring

# Cài đặt kube-prometheus-stack (Prometheus + Grafana)
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set grafana.adminPassword=admin123

# Mở Grafana UI (truy cập http://<your-vm-ip>:3000, user: admin, pass: admin123)
kubectl port-forward svc/prometheus-grafana -n monitoring 3000:80 --address 0.0.0.0
```

## Cleanup

### Delete DEV
```bash
# Xóa ứng dụng trong ArgoCD
kubectl delete -f argocd/mario-frontend-dev.yaml
kubectl delete -f argocd/mario-backend-dev.yaml

# Xóa namespace
kubectl delete namespace mario-game-dev
kubectl delete namespace argocd

# Xóa infrastructure
cd ~/mario-aks-gitops/terraform/environments/dev
terraform destroy -auto-approve
```

### Delete PROD
```bash
# Xóa ứng dụng trong ArgoCD
kubectl delete -f argocd/mario-frontend-prod.yaml
kubectl delete -f argocd/mario-backend-prod.yaml

# Xóa namespace
kubectl delete namespace mario-game-prod
kubectl delete namespace argocd

# Xóa infrastructure
cd ~/mario-aks-gitops/terraform/environments/prod
terraform destroy -auto-approve
```

### Delete Monitoring Stack
```bash
# Uninstall Prometheus stack
helm uninstall prometheus -n monitoring

# Xóa namespace monitoring
kubectl delete namespace monitoring
```
