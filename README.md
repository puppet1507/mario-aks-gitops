# Mario AKS GitOps - Quick Setup
Demo: [Google Drive](https://drive.google.com/drive/folders/1ZFN17gVmOwpiSlCxA7ZIl3kA9Z8jfimc?usp=sharing)

## Install Tools
```bash
sudo apt update && sudo apt upgrade -y

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

sudo apt install wget unzip -y
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
```

## Clone Repository
```bash
cd ~
git clone https://github.com/puppet1507/mario-aks-gitops.git
cd mario-aks-gitops
```

## Azure Login
```bash
az login
# Thay <your-subscription-id> bằng subscription ID của bạn
az account set --subscription "<your-subscription-id>"
```

## Deploy DEV
```bash
cd ~/mario-aks-gitops/terraform/environments/dev
terraform init
terraform apply -auto-approve

az aks get-credentials --resource-group mario-dev-rg --name mario-aks-dev --overwrite-existing

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Lấy password ArgoCD (username: admin)
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Truy cập https://<your-vm-ip>:8080
kubectl port-forward svc/argocd-server -n argocd 8080:443 --address 0.0.0.0

cd ~/mario-aks-gitops
kubectl apply -f argocd/mario-frontend-dev.yaml
kubectl apply -f argocd/mario-backend-dev.yaml
```

## Deploy PROD
```bash
cd ~/mario-aks-gitops/terraform/environments/prod
terraform init
terraform apply -auto-approve

az aks get-credentials --resource-group mario-prod-rg --name mario-aks-prod --overwrite-existing

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Lấy password ArgoCD (username: admin)
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Truy cập https://<your-vm-ip>:8080
kubectl port-forward svc/argocd-server -n argocd 8080:443 --address 0.0.0.0

# Truy cập http://<your-vm-ip>:8081
kubectl port-forward svc/nginx-ingress-ingress-nginx-controller 8081:80 -n ingress-nginx

cd ~/mario-aks-gitops
kubectl apply -f argocd/mario-frontend-prod.yaml
kubectl apply -f argocd/mario-backend-prod.yaml
kubectl apply -f argocd/argo-ingress-prod.yaml
```

## Optional: Monitoring Stack
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create namespace monitoring

helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set grafana.adminPassword=admin123

# Truy cập http://<your-vm-ip>:3000 (user: admin, pass: admin123)
kubectl port-forward svc/prometheus-grafana -n monitoring 3000:80 --address 0.0.0.0
```

## Cleanup

### Delete DEV
```bash
kubectl delete -f argocd/mario-frontend-dev.yaml
kubectl delete -f argocd/mario-backend-dev.yaml
kubectl delete namespace mario-game-dev
kubectl delete namespace argocd

cd ~/mario-aks-gitops/terraform/environments/dev
terraform destroy -auto-approve
```

### Delete PROD
```bash
kubectl delete -f argocd/mario-frontend-prod.yaml
kubectl delete -f argocd/mario-backend-prod.yaml
kubectl delete namespace mario-game-prod
kubectl delete namespace argocd

cd ~/mario-aks-gitops/terraform/environments/prod
terraform destroy -auto-approve
```

### Delete Monitoring Stack
```bash
helm uninstall prometheus -n monitoring
kubectl delete namespace monitoring
```
