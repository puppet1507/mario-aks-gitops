resource_group_name = "mario-prod-rg"
location            = "East Asia"
cluster_name        = "mario-aks-prod"
dns_prefix          = "mario-prod"
#kubernetes_version  = "1.28"
node_count          = 2
vm_size             = "Standard_B2s_v2"

vnet_address_space = ["10.20.0.0/16"]
aks_subnet_prefix  = ["10.20.1.0/24"]

tags = {
  Environment = "Production"
  Project     = "Mario-Game"
  ManagedBy   = "Terraform"
}

