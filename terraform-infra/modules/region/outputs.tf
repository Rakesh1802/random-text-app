#SThis is outputs.tf for region.
output "sql_server_id" {
  value       =  azurerm_mssql_server.sql_server.id
  description = "Sql server ID"
  sensitive   = false
}

output "app_hostname" {
  value       =  azurerm_linux_web_app.web.default_hostname
  description = "App host name"
  sensitive   = false
}

output "app_id" {
  value       =  azurerm_linux_web_app.web.id
  description = "App host name"
  sensitive   = false
}