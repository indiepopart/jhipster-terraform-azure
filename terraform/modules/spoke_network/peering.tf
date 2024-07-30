resource "azurerm_virtual_network_peering" "spoke_to_hub_peer" {
  name                      = "spoke-to-hub"
  resource_group_name       = azurerm_resource_group.rg_spoke_networks.name
  virtual_network_name      = azurerm_virtual_network.spoke_vnet.name
  remote_virtual_network_id = var.hub_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit = false
  use_remote_gateways = false

  depends_on = [
    var.hub_vnet_id,
    azurerm_virtual_network.spoke_vnet
  ]
}

resource "azurerm_virtual_network_peering" "hub_to_spoke_peer" {
  name                      = "hub-to-spoke"
  resource_group_name       = var.hub_rg_name
  virtual_network_name      = var.hub_vnet_name
  remote_virtual_network_id = azurerm_virtual_network.spoke_vnet.id
  allow_forwarded_traffic = false
  allow_virtual_network_access = true
  allow_gateway_transit = false
  use_remote_gateways = false

  depends_on = [
    var.hub_vnet_id,
    azurerm_virtual_network.spoke_vnet
  ]

}

resource "azurerm_private_dns_zone" "dns_zone_acr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.rg_spoke_networks.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr_network_link" {
  name                  = "dns-link-acr"
  resource_group_name   = azurerm_resource_group.rg_spoke_networks.name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone_acr.name
  virtual_network_id    = azurerm_virtual_network.spoke_vnet.id
}