resource "azurerm_firewall" "azure_firewall" {
  name                = local.hub_fw_name
  location            = azurerm_resource_group.rg_hub_networks.location
  resource_group_name = azurerm_resource_group.rg_hub_networks.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  zones               = ["1", "2", "3"]
  threat_intel_mode   = "Alert"
  dns_proxy_enabled    = true

  ip_configuration {
    name                 = local.pip_name
    subnet_id            = azurerm_subnet.azure_firewall_subnet.id
    public_ip_address_id = azurerm_public_ip.hub_pip.id
  }
}

resource "azurerm_ip_group" "aks_ip_group" {
  name                = "aks_ip_group"
  location            = azurerm_resource_group.rg_hub_networks.location
  resource_group_name = azurerm_resource_group.rg_hub_networks.name

  cidrs = [var.cluster_nodes_address_space]

}

