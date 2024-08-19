variable "resource_group_location" {
  description = "The location of the resource group"
}

variable "hub_vnet_address_space" {
  description = "The address space for the hub virtual network."
  default     = "10.200.0.0/24"
}

variable "azure_firewall_address_space" {
  description = "The address space for the Azure Firewall subnet."
  default     = "10.200.0.0/26"
}

variable "cluster_nodes_address_space" {
  description = "The address space for the cluster nodes."
}
