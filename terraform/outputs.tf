output "resource_group_name" {
  value = azurerm_resource_group.rg_ecommerce.name
}

output "kube_config" {
  value = module.cluster.kube_config
  sensitive = true
}

output "kubernetes_cluster_name" {
  value = module.cluster.kubernetes_cluster_name
}

output "acr_id" {
  value = module.acr.acr_id
}

output "hub_vnet_id" {
  value = module.hub_network.hub_vnet_id
}

output "spoke_vnet_id" {
  value = module.spoke_network.spoke_vnet_id
}

output "spoke_rg_name" {
  value = module.spoke_network.spoke_rg_name
}

output "hub_rg_name" {
  value = module.hub_network.hub_rg_name
}

output "hub_fw_private_ip" {
  value = module.hub_network.hub_fw_private_ip
}

output "hub_pip" {
  value = module.hub_network.hub_pip
}

output "spoke_pip" {
  value = module.spoke_network.spoke_pip
}

output "azure_firewall_id" {
  value = module.hub_network.azure_firewall_id
}

output "azure_application_gateway_id" {
  value = module.spoke_network.application_gateway_id
}
