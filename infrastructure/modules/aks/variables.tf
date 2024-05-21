variable "tags" {
  description = "(Required) Tags required for the resources"
}

variable "location" {
  type = string
  description = "(Required) Location of the resources"
}

variable "resource_group_name" {
  type = string
  description = "(Required) Resource group name"
}

variable "node_resource_group_name" {
  type = string
  description = "(Required) Resource group name for the nodes"
}



variable "cluster" {
  type = object(
  {
      name                          = string
      tier                          = string
      vnet_name                     = string
      vnet_address_space            = list(string)
      vnet_subnet_address_prefixes  = list(string)
      vnet_subnet_name              = string
      log_analytics_name            = string
      log_analytics_sku             = string
      container_registry_name       = string
      container_registry_sku        = string      
      private_cluster               = bool
      system_node_pool              = object({
        size         = string
        min_nodes    = number
        max_nodes    = number
        os_disk_type = string
        os_sku       = string
      })
      apps_node_pool                = object({
        size            = string
        min_nodes       = number
        max_nodes       = number
        os_disk_type    = string
        os_sku          = string
        os_disk_size_gb = number
      })
  })
  description = "(Required) Cluster Configuration"
}
