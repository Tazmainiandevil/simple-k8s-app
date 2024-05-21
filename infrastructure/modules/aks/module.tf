resource "azurerm_virtual_network" "vnet" {
  address_space       = var.cluster.vnet_address_space
  location            = var.location
  name                = var.cluster.vnet_name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet" "subnet" {
  address_prefixes     = var.cluster.vnet_subnet_address_prefixes
  name                 = var.cluster.vnet_subnet_name
  resource_group_name  = var.resource_group_name
  service_endpoints    = ["Microsoft.ContainerRegistry"]
  virtual_network_name = azurerm_virtual_network.vnet.name
  depends_on = [
    azurerm_virtual_network.vnet,
  ]
}

resource "azurerm_log_analytics_workspace" "log" {
  location            = var.location
  name                = var.cluster.log_analytics_name
  resource_group_name = var.resource_group_name
  sku                 = var.cluster.log_analytics_sku
}

resource "azurerm_kubernetes_cluster" "cluster" {
  automatic_channel_upgrade = "patch"
  dns_prefix                = "${var.cluster.name}-dns"
  location                  = var.location
  tags                      = var.tags
  resource_group_name       = var.resource_group_name
  name                      = var.cluster.name
  sku_tier                  = var.cluster.tier
  node_resource_group       = var.node_resource_group_name
  private_cluster_enabled   = var.cluster.private_cluster
  default_node_pool {
    tags                  = var.tags
    enable_auto_scaling   = true    
    max_count             = var.cluster.system_node_pool.max_nodes
    min_count             = var.cluster.system_node_pool.min_nodes    
    name                  = "agentpool"
    vm_size               = var.cluster.system_node_pool.size
    vnet_subnet_id        = azurerm_subnet.subnet.id
    os_disk_type          = var.cluster.system_node_pool.os_disk_type
    os_sku                = var.cluster.system_node_pool.os_sku
    upgrade_settings {
       max_surge = "10%"
    }
  }
  identity {
    type = "SystemAssigned"
  }
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.log.id
  }
  depends_on = [
    azurerm_subnet.subnet,
    azurerm_log_analytics_workspace.log
  ]
}

resource "azurerm_kubernetes_cluster_node_pool" "user_nodes" {
  tags                  = var.tags
  enable_auto_scaling   = true
  kubernetes_cluster_id = azurerm_kubernetes_cluster.cluster.id
  max_count             = var.cluster.apps_node_pool.max_nodes
  min_count             = var.cluster.apps_node_pool.min_nodes
  mode                  = "User"
  name                  = "apps"
  vm_size               = var.cluster.apps_node_pool.size
  node_labels           = { "serviceType" = "app" }
  vnet_subnet_id        = azurerm_subnet.subnet.id
  os_disk_type          = var.cluster.apps_node_pool.os_disk_type
  os_sku                = var.cluster.apps_node_pool.os_sku
  os_disk_size_gb       = var.cluster.apps_node_pool.os_disk_size_gb
  upgrade_settings {
    max_surge = "10%"
  }
  depends_on = [
    azurerm_subnet.subnet,
    azurerm_kubernetes_cluster.cluster,
  ]
}

resource "azurerm_container_registry" "registry" {
  admin_enabled       = true
  location            = var.location
  tags                = var.tags
  resource_group_name = var.resource_group_name
  name                = var.cluster.container_registry_name  
  sku                 = var.cluster.container_registry_sku
  depends_on = [
    azurerm_kubernetes_cluster.cluster,
  ]
}

resource "azurerm_role_assignment" "acrpull_role" {
  scope                            = azurerm_container_registry.registry.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.cluster.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
   depends_on = [
    azurerm_kubernetes_cluster.cluster,
    azurerm_container_registry.registry
  ]
}
