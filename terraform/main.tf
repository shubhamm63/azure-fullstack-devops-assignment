terraform {
  required_version = ">= 1.6.0"

  backend "azurerm" {
    resource_group_name  = "rg-fullstack-tfstate"
    storage_account_name = "fullstacktfstate2026"
    container_name       = "terraform-state"
    key                  = "fullstack-devops.tfstate"
  }
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = var.environment
    Project     = "fullstack-devops-assignment"
    ManagedBy   = "Terraform"
  }
}