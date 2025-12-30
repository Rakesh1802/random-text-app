# main.tf for forntdoor
resource "azurerm_cdn_frontdoor_profile" "fd" {
  name                = "fd-prod"
  resource_group_name = var.resource_group_name
  sku_name            = "Standard_AzureFrontDoor"
}

resource "azurerm_cdn_frontdoor_endpoint" "endpoint" {
  name                     = "app-endpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd.id
}

resource "azurerm_cdn_frontdoor_origin_group" "og" {
  name                     = "app-origins"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd.id

  health_probe {
    path                = "/health"
    protocol            = "Https"
    interval_in_seconds = 30
  }

  load_balancing {
    additional_latency_in_milliseconds = 50
    sample_size                        = 4
    successful_samples_required        = 3
  }
}

resource "azurerm_cdn_frontdoor_origin" "primary" {
  name                          = "primary"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.og.id
  host_name                     = var.primary_app_hostname
  priority                      = 1
  certificate_name_check_enabled = true
}

resource "azurerm_cdn_frontdoor_origin" "secondary" {
  name                          = "secondary"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.og.id
  host_name                     = var.secondary_app_hostname
  priority                      = 2
  certificate_name_check_enabled = true
}

resource "azurerm_cdn_frontdoor_route" "route" {
  name                          = "default-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.og.id

  cdn_frontdoor_origin_ids = [
    azurerm_cdn_frontdoor_origin.primary.id,
  azurerm_cdn_frontdoor_origin.secondary.id
  ]

  patterns_to_match   = ["/*"]
  supported_protocols = ["Https"]

  forwarding_protocol = "HttpsOnly"
}
