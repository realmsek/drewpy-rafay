terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.74.0"
    }
  }

  required_version = ">= 1.3.1"

  backend "azurerm" {
    subscription_id      = "59ef9ece-1d73-4fb1-b9a5-fb3cc58b0258"
    use_azuread_auth     = true
    resource_group_name  = "tfstate-rg"
    storage_account_name = "terraformstatesa9g2j9m"
    container_name       = "tfstate"
    key                  = "aks-nonprod.tfstate"

  }
}
