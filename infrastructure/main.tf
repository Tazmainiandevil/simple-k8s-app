resource "azurerm_resource_group" "resource_group" {
  location = "westeurope"
  name     = "rg-aks-dev-weu"
  tags     = { Owner = "DevOps", Environment = "Development" }
}

module "aks-resources" {
  source                   = "./modules/aks"
  tags                     = azurerm_resource_group.resource_group.tags
  location                 = azurerm_resource_group.resource_group.location
  resource_group_name      = azurerm_resource_group.resource_group.name
  node_resource_group_name = "rg-monolith-aks-nodes-dev-weu"
  cluster                  = {
    name                         = "monolith-aks-dev-weu"
    tier                         = "Standard"
    vnet_name                    = "monolith-vnet-dev-weu"
    vnet_address_space           = ["10.224.0.0/12"]
    vnet_subnet_address_prefixes = ["10.224.0.0/16"]
    vnet_subnet_name             = "aks"
    log_analytics_name           = "monolith-log-dev-weu"
    log_analytics_sku            = "PerGB2018"
    container_registry_name      = "monolithacrdevweu"
    container_registry_sku       = "Basic" 
    private_cluster              = false
    system_node_pool             = {
      size         = "Standard_D2s_v3"
      min_nodes    = 1
      max_nodes    = 3
      os_disk_type = "Managed"
      os_sku       = "AzureLinux"
    }
    apps_node_pool               = {
      size            = "Standard_D2s_v3"
      min_nodes       = 0
      max_nodes       = 5
      os_disk_type    = "Ephemeral"
      os_sku          = "AzureLinux"
      os_disk_size_gb = "50"
    }
  }
}