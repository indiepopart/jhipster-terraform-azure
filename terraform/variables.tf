variable "resource_group_location" {
  description = "The location of the resource group"
  default     = "westus2"
}

variable "application_id" {
  description = "The application id"
  default = "jhipster-microservices"
}

variable "cluster_nodes_address_space" {
  description = "The address space for the cluster nodes."
  default = "10.240.0.0/22"
}

variable "host_name" {
  description = "The host name"
  default = "store.example.com"
}
