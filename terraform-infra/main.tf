resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

resource "azurerm_service_plan" "asp" {
  name                = "asp-web-${random_integer.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "B1"
}

# Reference the existing Key Vault
data "azurerm_key_vault" "existing" {
  name                 = "my-key-vault-101"
  resource_group_name  = "my-key-vault-rg"
}

data "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  key_vault_id = data.azurerm_key_vault.existing.id
}

resource "azurerm_linux_web_app" "web" {
  name                = "webapp-${random_integer.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.asp.id

  https_only = true

  site_config {
    application_stack {
      node_version = "18-lts"
    }
  }

  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE = "1",
    DB_NAME = var.sql_db_name,
    DB_USER = var.sql_admin_username,
    DB_PASSWORD = data.azurerm_key_vault_secret.db_password.value
    DB_SERVER = azurerm_mssql_server.sql_server.fully_qualified_domain_name
  }
}

resource "azurerm_mssql_server" "sql_server" {
  name                         = "sqlserver-${random_integer.suffix.result}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = data.azurerm_key_vault_secret.db_password.value
}

resource "azurerm_mssql_database" "sql_db" {
  name      = var.sql_db_name
  server_id = azurerm_mssql_server.sql_server.id
  sku_name  = "Basic"
}

resource "azurerm_mssql_firewall_rule" "allow_azure" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
