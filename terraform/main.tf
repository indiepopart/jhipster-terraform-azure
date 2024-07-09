resource "azurerm_resource_group" "rg_ecommerce" {
  name     = "rg-ecommerce-${var.resource_group_location}"
  location = var.resource_group_location

  tags = {
    displayName = "Resource Group for general purpose"
  }
}

module "acr" {
  source = "./modules/acr"

  resource_group_name = azurerm_resource_group.rg_ecommerce.name
  resource_group_location = azurerm_resource_group.rg_ecommerce.location
}

module "hub_network" {
  source = "./modules/hub_network"
  resource_group_location = azurerm_resource_group.rg_ecommerce.location
  cluster_nodes_address_space = var.cluster_nodes_address_space
}

module "spoke_network" {
  source = "./modules/spoke_network"
  resource_group_location    = azurerm_resource_group.rg_ecommerce.location
  application_id             = var.application_id
  host_name                  = var.host_name
  cluster_nodes_address_space = var.cluster_nodes_address_space
  hub_fw_private_ip          = module.hub_network.hub_fw_private_ip
  hub_fw_public_ip           = module.hub_network.hub_pip
  hub_vnet_id                = module.hub_network.hub_vnet_id
  hub_vnet_name              = module.hub_network.hub_vnet_name
  hub_rg_name                = module.hub_network.hub_rg_name

  depends_on = [
    module.hub_network.hub_pip,
    module.hub_network.hub_vnet_id,
    module.acr.acr_id,
  ]
}

module "cluster" {
  source = "./modules/cluster"

  resource_group_location = module.spoke_network.spoke_rg_location
  resource_group_name     = module.spoke_network.spoke_rg_name
  resource_group_id       = module.spoke_network.spoke_rg_id
  acr_id                  = module.acr.acr_id
  vnet_subnet_id          = module.spoke_network.cluster_nodes_subnet_id
  application_gateway_id  = module.spoke_network.application_gateway_id
  spoke_pip_id            = module.spoke_network.spoke_pip_id

  depends_on = [
    module.spoke_network.cluster_nodes_route_table_association_id,
    module.spoke_network.spoke_to_hub_peer_id,
    module.spoke_network.hub_to_spoke_peer_id,
    module.spoke_network.spoke_pip_id,
    module.spoke_network.application_gateway_id,
    module.hub_network.fw_net_rule_org_wide_id,
    module.hub_network.fw_net_rule_aks_global_id,
    module.hub_network.fw_app_rule_aks_global_id,
  ]
}
