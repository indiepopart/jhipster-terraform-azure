output "resource_group_name" {
  value = azurerm_resource_group.rg_ecommerce.name
}

output "kube_config" {
  value     = module.cluster.kube_config
  sensitive = true
}

output "kubernetes_cluster_name" {
  value = module.cluster.kubernetes_cluster_name
}

output "spoke_pip" {
  value = module.spoke_network.spoke_pip
}

