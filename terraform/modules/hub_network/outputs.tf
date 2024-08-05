output "hub_vnet_id" {
  value = azurerm_virtual_network.hub_vnet.id
}

output "hub_vnet_name" {
  value = azurerm_virtual_network.hub_vnet.name
}

output "hub_fw_private_ip" {
  value = azurerm_firewall.azure_firewall.ip_configuration.0.private_ip_address
}

output "hub_rg_name" {
  value = azurerm_resource_group.rg_hub_networks.name
}

output "hub_pip" {
  value = azurerm_public_ip.hub_pip.ip_address
}
