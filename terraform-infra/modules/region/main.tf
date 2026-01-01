# main.tf for region

# Generate random suffix
resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

# Access current provider configuration
data "azurerm_client_config" "current" {}

# Reference the existing Key Vault
data "azurerm_key_vault" "existing" {
  name                 = "my-key-vault-101"
  resource_group_name  = "my-key-vault-rg"
}

# Fetch DB password
data "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  key_vault_id = data.azurerm_key_vault.existing.id
}

# Virtual Network configuration
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.location}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.${var.is_primary ? 0 : 1}.0/24"]
}

# App subnet
resource "azurerm_subnet" "appsvc" {
  name                 = "snet-appservice-${var.location}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.${var.is_primary ? 0 : 1}.0/26"]

  delegation {
    name = "appsvc-delegation"

    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }
}

# App subnet private
resource "azurerm_subnet" "private" {
  name                 = "snet-private-endpoints-${var.location}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.${var.is_primary ? 0 : 1}.64/27"]

  private_endpoint_network_policies = "Disabled"
}

# App service plan
resource "azurerm_service_plan" "asp" {
  name                = "asp-web-${var.location}-${random_integer.suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "S1"
  worker_count        = 2
}

# Web app
resource "azurerm_linux_web_app" "web" {
  name                = "webapp-${var.location}-${random_integer.suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.asp.id

  https_only = true

  # Assign the shared identity
  identity {
    type         = "UserAssigned"
    identity_ids = [var.oidc_db_id]
  }

  site_config {
    application_stack {
      node_version = "20-lts"
    }
    always_on = true
  }

  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE = "1",
    DB_NAME         = var.db_name,
    AZURE_CLIENT_ID = var.oidc_db_client_id
    DB_SERVER       = "${var.fog_db_name}.database.windows.net"
  }

  lifecycle {
    ignore_changes = [
      virtual_network_subnet_id,
    ]
  }
}

# VNET Integration
resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
  app_service_id = azurerm_linux_web_app.web.id
  subnet_id     = azurerm_subnet.appsvc.id
}

# SQL server
resource "azurerm_mssql_server" "sql_server" {
  name                         = "sqlserver-${var.location}-${random_integer.suffix.result}"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = data.azurerm_key_vault_secret.db_password.value

  azuread_administrator {
    login_username = "aad-admin"
    object_id      = data.azurerm_client_config.current.object_id
    tenant_id      = data.azurerm_client_config.current.tenant_id
    
    azuread_authentication_only = false 
  }

  public_network_access_enabled = false
}

# SQL PE
resource "azurerm_private_endpoint" "sql_pe" {
  name                = "pe-sql-${var.location}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.private.id

  private_service_connection {
    name                           = "sql-connection"
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "sql-dns-zone-group"
    private_dns_zone_ids = [var.dns_zone_id]
  }
}

