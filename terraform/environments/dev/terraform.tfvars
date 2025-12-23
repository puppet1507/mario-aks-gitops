resource_group_name = "mario-dev-rg"
location            = "East Asia"
cluster_name        = "mario-aks-dev"
dns_prefix          = "mario-dev"
#kubernetes_version  = "1.28"
node_count          = 1
vm_size             = "Standard_B2s_v2"

vnet_address_space = ["10.10.0.0/16"]
aks_subnet_prefix  = ["10.10.1.0/24"]

tags = {
  Environment = "Development"
  Project     = "Mario-Game"
  ManagedBy   = "Terraform"
}

