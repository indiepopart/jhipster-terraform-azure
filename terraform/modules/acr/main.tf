resource "azurerm_container_registry" "acr" {
  name                     = var.acr_name
  resource_group_name      = var.resource_group_name
  location                 = var.resource_group_location
  sku                      = "Premium"
  admin_enabled            = false
  quarantine_policy_enabled = false

  network_rule_set {
    default_action = "Allow"
  }

  trust_policy {
    enabled = false
  }

  retention_policy {
    days = 15
    enabled = true
  }

  tags = {
    displayName = "Container Registry"
  }
}

