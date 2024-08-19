variable "resource_group_location" {
  description = "The location of the spoke resource group."
}

variable "hub_fw_private_ip" {
  description = "The private IP address of the hub firewall."
}

variable "hub_fw_public_ip" {
  description = "The public IP address of the hub firewall."
}

variable "application_id" {
  description = "The identifier for the application."
}

variable "spoke_vnet_address_space" {
  description = "The address space for the spoke virtual network."
  default     = "10.240.0.0/16"
}

variable "cluster_nodes_address_space" {
  description = "The address space for the cluster nodes."
  default     = "10.240.0.0/22"
}

variable "application_gateways_address_space" {
  description = "The address space for the application gateways."
  default     = "10.240.4.16/28"
}

variable "hub_vnet_id" {
  description = "The ID of the hub virtual network."
}

variable "hub_vnet_name" {
  description = "The name of the hub virtual network."
}

variable "hub_rg_name" {
  description = "The name of the hub resource group."
}

variable "host_name" {
  description = "The host name"
}
