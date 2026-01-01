# Outputs for the module resource-group

output "rg_id" {
  value       = azurerm_resource_group.rg.id
  description = "resource group id"
  sensitive   = false
}