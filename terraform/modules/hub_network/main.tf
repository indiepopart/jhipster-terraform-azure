locals {
  pip_name   = "pip-fw-${var.resource_group_location}-default"
  hub_fw_name   = "fw-${var.resource_group_location}-hub"
  hub_vnet_name = "vnet-${var.resource_group_location}-hub"
  hub_rg_name   = "rg-hubs-${var.resource_group_location}"
}

resource "azurerm_resource_group" "rg_hub_networks" {
  name = local.hub_rg_name
  location = var.resource_group_location

  tags = {
    displayName = "Resource Group for Hub networks"
  }
}

resource "azurerm_virtual_network" "hub_vnet" {
  name                = local.hub_vnet_name
  location            = azurerm_resource_group.rg_hub_networks.location
  resource_group_name = azurerm_resource_group.rg_hub_networks.name
  address_space       = [var.hub_vnet_address_space]
}

resource "azurerm_subnet" "azure_firewall_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.rg_hub_networks.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes       = [var.azure_firewall_address_space]
  service_endpoints    = ["Microsoft.KeyVault"]
}

resource "azurerm_public_ip" "hub_pip" {
  name                = local.pip_name
  location            = azurerm_resource_group.rg_hub_networks.location
  resource_group_name = azurerm_resource_group.rg_hub_networks.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones              = ["1", "2", "3"]
  idle_timeout_in_minutes = 4
}




