resource "azurerm_firewall" "azure_firewall" {
  name                = local.hub_fw_name
  location            = azurerm_resource_group.rg_hub_networks.location
  resource_group_name = azurerm_resource_group.rg_hub_networks.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard" # requried for network rules
  zones               = ["1", "2", "3"]
  dns_proxy_enabled   = true # required for network rules with fqdns (tcp to docker.io)

  ip_configuration {
    name                 = local.pip_name
    subnet_id            = azurerm_subnet.azure_firewall_subnet.id
    public_ip_address_id = azurerm_public_ip.hub_pip.id
  }
}

