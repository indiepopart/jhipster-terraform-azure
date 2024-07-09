output "spoke_vnet_id" {
  value = azurerm_virtual_network.spoke_vnet.id
}

output "cluster_nodes_subnet_id" {
  value = azurerm_subnet.cluster_nodes_subnet.id
}

output "application_gateway_subnet_id" {
  value = azurerm_subnet.application_gateways_subnet.id
}

output "cluster_nodes_route_table_association_id" {
  value = azurerm_subnet_route_table_association.cluster_nodes_route_table.id
}

output "spoke_pip" {
  value = azurerm_public_ip.spoke_pip.ip_address
}

output "spoke_pip_id" {
  value = azurerm_public_ip.spoke_pip.id
}

output "spoke_pip_name" {
  value = azurerm_public_ip.spoke_pip.name
}

output "hub_to_spoke_peer_id" {
  value = azurerm_virtual_network_peering.hub_to_spoke_peer.id
}

output "spoke_to_hub_peer_id" {
  value = azurerm_virtual_network_peering.spoke_to_hub_peer.id
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

