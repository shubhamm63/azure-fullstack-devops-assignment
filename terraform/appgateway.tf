resource "azurerm_public_ip" "app_gateway" {
  name                = "pip-fullstack-appgw"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "main" {
  name                = "appgw-fullstack-devops"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  sku {
    name = "Standard_v2"
    tier = "Standard_v2"
  }

  autoscale_configuration {
    min_capacity = 1
    max_capacity = 2
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = azurerm_subnet.public.id
  }

  frontend_port {
    name = "frontend-port-80"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "appgw-public-ip"
    public_ip_address_id = azurerm_public_ip.app_gateway.id
  }

  backend_address_pool {
    name  = "frontend-backend-pool"
    fqdns = [azurerm_linux_web_app.frontend.default_hostname]
  }

  probe {
    name                = "frontend-health-probe"
    protocol            = "Http"
    path                = "/"
    host                = azurerm_linux_web_app.frontend.default_hostname
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
  }

  backend_http_settings {
    name                  = "frontend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"

    request_timeout = 30

    probe_name = "frontend-health-probe"

    host_name = azurerm_linux_web_app.frontend.default_hostname
  }

  http_listener {
    name                           = "frontend-listener"
    frontend_ip_configuration_name = "appgw-public-ip"
    frontend_port_name             = "frontend-port-80"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "frontend-routing-rule"
    priority                   = 100
    rule_type                  = "Basic"
    http_listener_name         = "frontend-listener"
    backend_address_pool_name  = "frontend-backend-pool"
    backend_http_settings_name = "frontend-http-settings"
  }

  tags = {
    Environment = var.environment
    Project     = "fullstack-devops-assignment"
    ManagedBy   = "Terraform"
  }
}