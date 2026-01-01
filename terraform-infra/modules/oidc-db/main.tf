resource "azurerm_user_assigned_identity" "db_identity" {
  name                = "oidc-db-${var.location}" 
  location            = var.location
  resource_group_name = var.primary_rg_name
}


