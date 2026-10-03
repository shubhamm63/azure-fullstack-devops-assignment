resource "azurerm_service_plan" "main" {
  name                = "asp-fullstack-devops"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  os_type  = "Linux"
  sku_name = "B1"

  tags = {
    Environment = var.environment
    Project     = "fullstack-devops-assignment"
    ManagedBy   = "Terraform"
  }
}

# -------------------------
# User Assigned Identities
# -------------------------

resource "azurerm_user_assigned_identity" "backend" {
  name                = "id-fullstack-backend"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  tags = {
    Environment = var.environment
    Project     = "fullstack-devops-assignment"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_user_assigned_identity" "frontend" {
  name                = "id-fullstack-frontend"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  tags = {
    Environment = var.environment
    Project     = "fullstack-devops-assignment"
    ManagedBy   = "Terraform"
  }
}

# -------------------------
# Backend App Service
# -------------------------

resource "azurerm_linux_web_app" "backend" {
  name                = "app-fullstack-backend-2026"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_service_plan.main.location
  service_plan_id     = azurerm_service_plan.main.id

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.backend.id]
  }

  site_config {
    always_on = false

    container_registry_use_managed_identity       = true
    container_registry_managed_identity_client_id = azurerm_user_assigned_identity.backend.client_id

    application_stack {
      docker_image_name   = "backend:v1"
      docker_registry_url = "https://${azurerm_container_registry.main.login_server}"
    }
  }

  app_settings = {
    WEBSITES_PORT = "8000"
    PORT          = "8000"

    DATABASE_URL = "postgresql://${var.db_admin_username}:${var.db_admin_password}@${azurerm_postgresql_flexible_server.main.fqdn}:5432/${var.db_name}?sslmode=require"
  }

  tags = {
    Environment = var.environment
    Project     = "fullstack-devops-assignment"
    ManagedBy   = "Terraform"
  }
}

# -------------------------
# Frontend App Service
# -------------------------

resource "azurerm_linux_web_app" "frontend" {
  name                = "app-fullstack-frontend-2026"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_service_plan.main.location
  service_plan_id     = azurerm_service_plan.main.id

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.frontend.id]
  }

  site_config {
    always_on = false

    container_registry_use_managed_identity       = true
    container_registry_managed_identity_client_id = azurerm_user_assigned_identity.frontend.client_id

    application_stack {
      docker_image_name   = "frontend:v3"
      docker_registry_url = "https://${azurerm_container_registry.main.login_server}"
    }
  }

  app_settings = {
    WEBSITES_PORT = "4173"
  }

  tags = {
    Environment = var.environment
    Project     = "fullstack-devops-assignment"
    ManagedBy   = "Terraform"
  }
}

# -------------------------
# ACR Pull Permissions
# -------------------------

resource "azurerm_role_assignment" "backend_acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.backend.principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "frontend_acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.frontend.principal_id
  principal_type       = "ServicePrincipal"
}

# -------------------------
# Backend VNet Integration
# -------------------------

resource "azurerm_app_service_virtual_network_swift_connection" "backend" {
  app_service_id = azurerm_linux_web_app.backend.id
  subnet_id      = azurerm_subnet.app.id
}