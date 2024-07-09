variable "resource_group_location" {
  description = "The location of the resource group"
}

variable "on_prem_gateway_addess_space" {
  description = "A /27 under the VNet Address Space for our On-Prem Gateway"
  default     = "10.200.0.64/27"
}

variable "bastion_address_space" {
  description = "A /27 under the VNet Address Space for Azure Bastion"
  default     = "10.200.0.96/27"
}

variable "hub_vnet_address_space" {
  description = "The address space for the hub virtual network."
  default = "10.200.0.0/24"
}

variable "azure_firewall_address_space" {
  description = "The address space for the Azure Firewall subnet."
  default = "10.200.0.0/26"
}

variable "cluster_nodes_address_space" {
  description = "The address space for the cluster nodes."
}