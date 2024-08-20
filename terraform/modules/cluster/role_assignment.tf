resource "azurerm_role_assignment" "cluster_identity_acrpull_role_assignment" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
}

resource "azurerm_role_assignment" "cluster_nodepool_role_assignment" {
  scope                = azurerm_kubernetes_cluster.k8s.node_resource_group_id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
}

resource "azurerm_role_assignment" "cluster_vnet_role_assignment" {
  scope                = var.vnet_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
}

resource "azurerm_role_assignment" "control_plane_vnet_role_assignment" {
  scope                = var.vnet_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.cluster_control_plane_identity.principal_id
}

resource "azurerm_role_assignment" "control_plane_pip_role_assignment" {
  scope                = var.spoke_pip_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.cluster_control_plane_identity.principal_id
}

resource "azurerm_role_assignment" "ingress_vnet_role_assignment" {
  scope                = var.vnet_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.k8s.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}

resource "azurerm_role_assignment" "ingress_pip_role_assignment" {
  scope                = var.spoke_pip_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.k8s.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}

resource "azurerm_role_assignment" "ingress_app_gateway_role_assignment" {
  scope                = var.application_gateway_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.k8s.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}

resource "azurerm_role_assignment" "ingress_rg_role_assignment" {
  scope                = var.resource_group_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.k8s.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}
