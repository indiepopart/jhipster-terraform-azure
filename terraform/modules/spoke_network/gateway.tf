locals {
  backend_address_pool_name      = "app-gateway-beap"
  frontend_port_name             = "app-gateway-feport"
  frontend_ip_configuration_name = "app-gateway-feip"
  http_setting_name              = "app-gateway-be-htst"
  listener_name                  = "app-gateway-httplstn"
  request_routing_rule_name      = "app-gateway-rqrt"
  redirect_configuration_name    = "app-gateway-rdrcfg"
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
