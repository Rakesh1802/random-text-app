# ================================
# VNet Peering: vnet1 -> vnet2
# ================================
resource "azurerm_virtual_network_peering" "vnet1_to_vnet2" {
  name                      = "${var.primary_vnet_name}-to-${var.secondary_vnet_name}"
  resource_group_name       = var.primary_rg_name
  virtual_network_name      = var.primary_vnet_name
  remote_virtual_network_id = var.secondary_vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# ================================
# VNet Peering: vnet2 -> vnet1
# ================================
resource "azurerm_virtual_network_peering" "vnet2_to_vnet1" {
  name                      = "${var.secondary_vnet_name}-to-${var.primary_vnet_name}"
  resource_group_name       = var.secondary_rg_name
  virtual_network_name      = var.secondary_vnet_name
  remote_virtual_network_id = var.primary_vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}