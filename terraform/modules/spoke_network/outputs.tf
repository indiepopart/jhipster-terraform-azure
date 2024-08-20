output "cluster_nodes_subnet_id" {
  value = azurerm_subnet.cluster_nodes_subnet.id
}

output "spoke_pip" {
  value = azurerm_public_ip.spoke_pip.ip_address
}

output "spoke_pip_id" {
  value = azurerm_public_ip.spoke_pip.id
}

output "spoke_rg_name" {
  value = azurerm_resource_group.rg_spoke_networks.name
}

output "spoke_rg_location" {
  value = azurerm_resource_group.rg_spoke_networks.location
}

output "spoke_rg_id" {
  value = azurerm_resource_group.rg_spoke_networks.id
}

output "application_gateway_id" {
  value = azurerm_application_gateway.gateway.id
}

