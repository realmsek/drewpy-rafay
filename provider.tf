provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = "74d335a8-d10d-4fca-aecc-b1ecade0f897"
}

