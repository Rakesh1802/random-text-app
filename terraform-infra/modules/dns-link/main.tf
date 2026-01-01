# Private DNS zone
resource "azurerm_private_dns_zone" "sql_dns" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.resource_group_name
}

# Create DNS links with dns zone and vnets
resource "azurerm_private_dns_zone_virtual_network_link" "sql_links" {
  for_each = {
    centralindia   = var.primary_vnet_id
    eastasia  = var.secondary_vnet_id
  }

  name                  = "sql-dns-${each.key}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.sql_dns.name
  virtual_network_id    = each.value
}
