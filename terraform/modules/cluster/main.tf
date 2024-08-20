resource "random_pet" "azurerm_kubernetes_cluster_name" {
  prefix = "cluster"
}

resource "azurerm_user_assigned_identity" "cluster_control_plane_identity" {
  location            = var.resource_group_location
  name                = "${random_pet.azurerm_kubernetes_cluster_name.id}-controlplane"
  resource_group_name = var.resource_group_name
}

resource "azurerm_kubernetes_cluster" "k8s" {
  location                  = var.resource_group_location
  name                      = random_pet.azurerm_kubernetes_cluster_name.id
  resource_group_name       = var.resource_group_name
  dns_prefix                = random_pet.azurerm_kubernetes_cluster_name.id
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  tags = {
    displayName = "Kubernetes Cluster"
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.cluster_control_plane_identity.id
    ]
  }

  default_node_pool {
    name           = "agentpool"
    vm_size        = var.vm_size
    node_count     = var.node_count
    zones          = ["1", "2", "3"]
    vnet_subnet_id = var.vnet_subnet_id
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
    outbound_type  = "userDefinedRouting"
  }

  ingress_application_gateway {
    gateway_id = var.application_gateway_id
  }
}

