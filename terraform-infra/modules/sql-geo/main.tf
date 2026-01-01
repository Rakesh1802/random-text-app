# Create the database
resource "azurerm_mssql_database" "primary_db" {
  name      = var.db_name
  server_id = var.primary_server_id
  sku_name  = "Basic"
}

# DB failover groups
resource "azurerm_mssql_failover_group" "fg" {
  name      = "sql-fg"
  server_id = var.primary_server_id

  partner_server {
    id = var.secondary_server_id
  }

  databases = [
    azurerm_mssql_database.primary_db.id
  ]

  read_write_endpoint_failover_policy {
    mode          = "Automatic"
    grace_minutes = 60
  }
}

