resource "azurerm_traffic_manager_profile" "tm" {
  name                   = "tm-app-prod"
  resource_group_name    = var.resource_group_name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "app-prod"
    ttl           = 30
  }

  monitor_config {
    protocol = "HTTPS"
    port     = 443
    path     = "/health"
  }

}

resource "azurerm_traffic_manager_azure_endpoint" "primary" {
  name               = "primary-endpoint"
  profile_id         = azurerm_traffic_manager_profile.tm.id
  priority           = 1
  target_resource_id = var.primary_app_service_id
}

resource "azurerm_traffic_manager_azure_endpoint" "secondary" {
  name               = "secondary-endpoint"
  profile_id         = azurerm_traffic_manager_profile.tm.id
  priority           = 2
  target_resource_id = var.secondary_app_service_id
}

