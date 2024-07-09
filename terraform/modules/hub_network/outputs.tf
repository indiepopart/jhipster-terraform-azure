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

output "fw_net_rule_org_wide_id" {
  value = azurerm_firewall_network_rule_collection.org_wide_allow.id
}

output "fw_net_rule_aks_global_id" {
  value = azurerm_firewall_network_rule_collection.aks_global_allow.id
}

output "fw_app_rule_aks_global_id" {
  value = azurerm_firewall_application_rule_collection.aks_global_allow.id
}

output "azure_firewall_id" {
  value = azurerm_firewall.azure_firewall.id
}
