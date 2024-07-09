locals {
  spoke_vnet_name = "vnet-${var.resource_group_location}-spoke"
  spoke_rg_name = "rg-spokes-${var.resource_group_location}"
  pip_name = "pip-${var.application_id}-00"
  backend_address_pool_name      = "app-gwateway-beap"
  frontend_port_name             = "app-gateway-feport"
  frontend_ip_configuration_name = "app-gateway-feip"
  http_setting_name              = "app-gateway-be-htst"
  listener_name                  = "app-gateway-httplstn"
  request_routing_rule_name      = "app-gateway-rqrt"
  redirect_configuration_name    = "app-gateway-rdrcfg"
  gateway_pip_name               = "app-gateway-pip"
}

resource "azurerm_resource_group" "rg_spoke_networks" {
  name = local.spoke_rg_name
  location = var.resource_group_location

  tags = {
    displayName = "Resource Group for Spoke networks"
  }
}

resource "azurerm_virtual_network" "spoke_vnet" {
  name                = local.spoke_vnet_name
  location            = azurerm_resource_group.rg_spoke_networks.location
  resource_group_name = azurerm_resource_group.rg_spoke_networks.name
  address_space       = [var.spoke_vnet_address_space]
}

resource "azurerm_subnet" "cluster_nodes_subnet" {
  name                 = "snet-clusternodes"
  resource_group_name  = azurerm_resource_group.rg_spoke_networks.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes       = [var.cluster_nodes_address_space]
}

resource "azurerm_route_table" "spoke_route_table" {
  name                = "route-spoke-to-hub"
  location            = azurerm_resource_group.rg_spoke_networks.location
  resource_group_name = azurerm_resource_group.rg_spoke_networks.name

  route {
    name                = "r-nexthop-to-fw"
    address_prefix      = "0.0.0.0/0"
    next_hop_type       = "VirtualAppliance"
    next_hop_in_ip_address = var.hub_fw_private_ip
  }
  route {
    name                = "r-internet"
    address_prefix      = "${var.hub_fw_public_ip}/32"
    next_hop_type       = "Internet"
  }
}

resource "azurerm_subnet_route_table_association" "cluster_nodes_route_table" {
  subnet_id = azurerm_subnet.cluster_nodes_subnet.id
  route_table_id = azurerm_route_table.spoke_route_table.id
}

resource "azurerm_subnet" "ingress_services_subnet" {
  name                 = "snet-ingress-services"
  resource_group_name  = azurerm_resource_group.rg_spoke_networks.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes       = [var.ingress_services_address_space]

}

resource "azurerm_subnet" "application_gateways_subnet" {
  name                 = "snet-application-gateways"
  resource_group_name  = azurerm_resource_group.rg_spoke_networks.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes       = [var.application_gateways_address_space]

}

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

resource "azurerm_public_ip" "spoke_pip" {
  name                = local.pip_name
  location            = azurerm_resource_group.rg_spoke_networks.location
  resource_group_name = azurerm_resource_group.rg_spoke_networks.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones              = ["1","2", "3"]
  idle_timeout_in_minutes = 4
  ip_version = "IPv4"
}

resource "azurerm_application_gateway" "gateway" {
  name                = "app-gateway"
  location            = azurerm_resource_group.rg_spoke_networks.location
  resource_group_name = azurerm_resource_group.rg_spoke_networks.name
  zones               = ["1", "2", "3"]

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-configuration"
    subnet_id = azurerm_subnet.application_gateways_subnet.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.spoke_pip.id
  }

  waf_configuration {
    enabled = true
    firewall_mode = "Prevention"
    rule_set_type = "OWASP"
    rule_set_version = "3.0"
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    pick_host_name_from_backend_address = true
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
    host_name                      = var.host_name
    #require_sni                    = true
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 1
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}
