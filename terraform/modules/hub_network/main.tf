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

resource "azurerm_subnet" "gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg_hub_networks.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes       = [var.on_prem_gateway_addess_space]
  service_endpoints    = ["Microsoft.KeyVault"]
}

resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg_hub_networks.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes       = [var.bastion_address_space]
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
  ip_version = "IPv4"

}

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
    name = "ntp"
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
}

