terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "tfstate" {
  name     = "rg-fullstack-tfstate"
  location = "East US"

  tags = {
    Project   = "fullstack-devops-assignment"
    ManagedBy = "Terraform"
    Purpose   = "Terraform State"
  }
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "fullstacktfstate2026"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  blob_properties {
    versioning_enabled = true
  }

  tags = {
    Project   = "fullstack-devops-assignment"
    ManagedBy = "Terraform"
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "terraform-state"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}