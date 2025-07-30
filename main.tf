resource "azurerm_user_assigned_identity" "aks-nonprod-tf-mi" {
  location            = "eastus"
  name                = "aks-nonprod-tf-mi"
  resource_group_name = "aks-nonprod-tf-rg"
  tags = {
    controller = "terraform"
  }
}


resource "azurerm_resource_group" "aks-nonprod-aks01-rg" {
  name     = "aks-nonprod-aks01-rg"
  location = "eastus"
  tags = {
    controller = "terraform"
  }

}

resource "azurerm_kubernetes_cluster" "aks-nonprod-01" {
  name                                = "aks-nonprod-01"
  location                            = "eastus"
  resource_group_name                 = "aks-nonprod-aks01-rg"
  dns_prefix                          = "aks-nonprod-01-dns"
  # automatic_channel_upgrade           = "node-image"
  azure_policy_enabled                = true
  cost_analysis_enabled               = false
  # custom_ca_trust_certificates_base64 = []
  # enable_pod_security_policy = false
  http_application_routing_enabled = false
  image_cleaner_enabled            = false
  image_cleaner_interval_hours     = 48
  sku_tier                         = "Standard"
  depends_on = [
      azurerm_virtual_network.aks-nonprod-eastus-aks01-vnet
 ]
  default_node_pool {
    name                         = "agentpool"
    node_count                   = 2
    vm_size                      = "Standard_D2s_v3"
    auto_scaling_enabled         = true
    max_count                    = 4
    min_count                    = 2
    only_critical_addons_enabled = true
    vnet_subnet_id               = "/subscriptions/74d335a8-d10d-4fca-aecc-b1ecade0f897/resourceGroups/aks-nonprod-network-rg/providers/Microsoft.Network/virtualNetworks/aks-nonprod-eastus-aks01-vnet/subnets/aks-nonprod-eastus-sysnet-subnet"
    zones                        = [1, 2, 3]
    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
    temporary_name_for_rotation = "akstmp"
    tags = {
      controller = "terraform"
    }
  }
  maintenance_window_node_os {
    day_of_month = 0
    day_of_week  = "Friday"
    duration     = 4
    frequency    = "Weekly"
    interval     = 1
    start_date   = "2024-08-01T00:00:00Z"
    start_time   = "00:00"
    utc_offset   = "+00:00"
  }
  identity {
    type = "UserAssigned"
    identity_ids = [ azurerm_user_assigned_identity.aks-nonprod-tf-mi.id ]
  }

  tags = {
    controller = "terraform"
  }
}

resource "azurerm_resource_group" "aks-nonprod-network-rg" {
  name     = "aks-nonprod-network-rg"
  location = "eastus"
  tags = {
    controller = "terraform"
  }

}

resource "azurerm_network_security_group" "aks-nonprod-eastus-aks01-nsg" {
  name                = "aks-nonprod-eastus-aks01-nsg"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.aks-nonprod-network-rg.name
  tags = {
    controller = "terraform"
  }

}

resource "azurerm_virtual_network" "aks-nonprod-eastus-aks01-vnet" {
  name                = "aks-nonprod-eastus-aks01-vnet"
  location            = "eastus"
  resource_group_name = "aks-nonprod-network-rg"
  address_space       = ["10.80.0.0/20"]

  subnet {
    name           = "aks-nonprod-eastus-sysnet-subnet"
    address_prefixes = ["10.80.0.0/24"]
    security_group = azurerm_network_security_group.aks-nonprod-eastus-aks01-nsg.id
  }

  subnet {
    name           = "aks-nonprod-eastus-usernet1-subnet"
    address_prefixes = ["10.80.2.0/23"]
    security_group = azurerm_network_security_group.aks-nonprod-eastus-aks01-nsg.id
  }

  subnet {
    name           = "aks-nonprod-eastus-usernet2-subnet"
    address_prefixes = ["10.80.4.0/23"]
    security_group = azurerm_network_security_group.aks-nonprod-eastus-aks01-nsg.id
  }

  tags = {
    controller = "terraform"
  }
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.aks-nonprod-01.kube_config[0].client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks-nonprod-01.kube_config_raw

  sensitive = true
}

