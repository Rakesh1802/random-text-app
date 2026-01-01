#This is outputs.tf for the moudule sql-geo

output "fog_db_name" {
  value       = azurerm_mssql_failover_group.fg.name
  description = "What this output represents"
  sensitive   = false
}
