output "cluster_name" {
  value = module.aks.cluster_name
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "kube_config_command" {
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.rg.name} --name ${module.aks.cluster_name}"
}

output "cluster_id" {
  value = module.aks.cluster_id
}

