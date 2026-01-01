#This is outputs.tf for region.

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
  description = "App ID"
  sensitive   = false
}

output "vnet_name" {
  value       =  azurerm_virtual_network.vnet.name
  description = "Vnet Name"
  sensitive   = false
}

output "vnet_id" {
  value       =  azurerm_virtual_network.vnet.id
  description = "Vnet ID"
  sensitive   = false
}