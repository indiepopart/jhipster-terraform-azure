resource "azurerm_ip_group" "aks_ip_group" {
  name                = "aks_ip_group"
  location            = azurerm_resource_group.rg_hub_networks.location
  resource_group_name = azurerm_resource_group.rg_hub_networks.name

  cidrs = [var.cluster_nodes_address_space]
}

# See https://learn.microsoft.com/en-us/azure/aks/limit-egress-traffic?tabs=aks-with-system-assigned-identities#required-ports-and-addresses-for-aks-clusters
resource "azurerm_firewall_network_rule_collection" "org_wide_allow" {
  name                = "org-wide-allowed"
  azure_firewall_name = azurerm_firewall.azure_firewall.name
  resource_group_name = azurerm_resource_group.rg_hub_networks.name
  priority            = 100
  action              = "Allow"

  rule {
    name = "dns"

    source_addresses = [
      "*",
    ]

    protocols = [
      "UDP",
    ]

    destination_ports = [
      "53",
    ]

    destination_addresses = [
      "*",
    ]
  }

  rule {
    name        = "ntp"
    description = "Network Time Protocol (NTP) time synchronization"

    source_addresses = [
      "*",
    ]

    protocols = [
      "UDP",
    ]

    destination_ports = [
      "123",
    ]

    destination_addresses = [
      "*",
    ]
  }
}

resource "azurerm_firewall_network_rule_collection" "aks_global_allow" {
  name                = "aks-global-requirements"
  azure_firewall_name = azurerm_firewall.azure_firewall.name
  resource_group_name = azurerm_resource_group.rg_hub_networks.name
  priority            = 200
  action              = "Allow"

  rule {
    name = "tunnel-front-pod-tcp"

    source_ip_groups = [
      azurerm_ip_group.aks_ip_group.id,
    ]

    protocols = [
      "TCP",
    ]

    destination_ports = [
      "22",
      "9000"
    ]

    destination_addresses = [
      "AzureCloud",
    ]
  }

  rule {
    name = "tunnel-front-pod-udp"

    source_ip_groups = [
      azurerm_ip_group.aks_ip_group.id,
    ]

    protocols = [
      "UDP",
    ]

    destination_ports = [
      "1194",
      "123"
    ]

    destination_addresses = [
      "AzureCloud",
    ]
  }

  rule {
    name = "managed-k8s-api-tcp-443"

    source_ip_groups = [
      azurerm_ip_group.aks_ip_group.id,
    ]

    protocols = [
      "TCP",
    ]

    destination_ports = [
      "443",
    ]

    destination_addresses = [
      "AzureCloud",
    ]
  }

  rule {
    name = "docker"

    source_ip_groups = [
      azurerm_ip_group.aks_ip_group.id,
    ]

    protocols = [
      "TCP"
    ]

    destination_ports = [
      "443"
    ]

    destination_fqdns = [
      "docker.io",
      "registry-1.docker.io",
      "production.cloudflare.docker.com"
    ]
  }

  depends_on = [
    azurerm_firewall_network_rule_collection.org_wide_allow
  ]
}

resource "azurerm_firewall_application_rule_collection" "aks_global_allow" {
  name                = "aks-global-requirements"
  azure_firewall_name = azurerm_firewall.azure_firewall.name
  resource_group_name = azurerm_resource_group.rg_hub_networks.name
  priority            = 200
  action              = "Allow"

  rule {
    name = "nodes-to-api-server"

    source_ip_groups = [
      azurerm_ip_group.aks_ip_group.id,
    ]

    target_fqdns = [
      "*.hcp.eastus2.azmk8s.io",
      "*.tun.eastus2.azmk8s.io"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }

  rule {
    name = "microsoft-container-registry"

    source_ip_groups = [
      azurerm_ip_group.aks_ip_group.id,
    ]

    target_fqdns = [
      "*.cdn.mscr.io",
      "mcr.microsoft.com",
      "*.data.mcr.microsoft.com"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }

  rule {
    name = "management-plane"

    source_ip_groups = [
      azurerm_ip_group.aks_ip_group.id,
    ]

    target_fqdns = [
      "management.azure.com"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }

  rule {
    name = "aad-auth"

    source_ip_groups = [
      azurerm_ip_group.aks_ip_group.id,
    ]

    target_fqdns = [
      "login.microsoftonline.com"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }

  rule {
    name = "apt-get"

    source_ip_groups = [
      azurerm_ip_group.aks_ip_group.id,
    ]

    target_fqdns = [
      "packages.microsoft.com"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }

  rule {
    name = "cluster-binaries"

    source_ip_groups = [
      azurerm_ip_group.aks_ip_group.id,
    ]

    target_fqdns = [
      "acs-mirror.azureedge.net"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }

  rule {
    name = "ubuntu-security-patches"

    source_ip_groups = [
      azurerm_ip_group.aks_ip_group.id,
    ]

    target_fqdns = [
      "security.ubuntu.com",
      "azure.archive.ubuntu.com",
      "changelogs.ubuntu.com"
    ]

    protocol {
      port = "80"
      type = "Http"
    }
  }

  rule {
    name = "azure-monitor"

    source_ip_groups = [
      azurerm_ip_group.aks_ip_group.id,
    ]

    target_fqdns = [
      "dc.services.visualstudio.com",
      "*.ods.opinsights.azure.com",
      "*.oms.opinsights.azure.com",
      "*.microsoftonline.com",
      "*.monitoring.azure.com"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }

  rule {
    name = "azure-policy"

    source_ip_groups = [
      azurerm_ip_group.aks_ip_group.id,
    ]

    target_fqdns = [
      "gov-prod-policy-data.trafficmanager.net",
      "raw.githubusercontent.com",
      "dc.services.visualstudio.com",
      "data.policy.core.windows.net",
      "store.policy.core.windows.net"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }

  rule {
    name = "azure-kubernetes-service"

    source_ip_groups = [
      azurerm_ip_group.aks_ip_group.id,
    ]

    fqdn_tags = [
      "AzureKubernetesService"
    ]
  }

  rule {
    name = "auth0"

    source_ip_groups = [
      azurerm_ip_group.aks_ip_group.id,
    ]

    target_fqdns = [
      "*.auth0.com"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }

  depends_on = [
    azurerm_firewall_network_rule_collection.aks_global_allow
  ]
}

