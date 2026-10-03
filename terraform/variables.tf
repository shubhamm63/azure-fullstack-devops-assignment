variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "Central India"
}

variable "resource_group_name" {
  description = "Name of the Azure resource group."
  type        = string
  default     = "rg-docker-fullstack-demo"
}

variable "container_registry_name" {
  description = "Globally unique Azure Container Registry name."
  type        = string
  default     = "acrdockerfullstackdemo"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "fullstackdb"
}

variable "db_admin_username" {
  description = "PostgreSQL administrator username"
  type        = string
  default     = "appadmin"
}

variable "db_admin_password" {
  description = "PostgreSQL administrator password"
  type        = string
  sensitive   = true
}
