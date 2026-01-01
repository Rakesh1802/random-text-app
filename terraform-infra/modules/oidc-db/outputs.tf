# Outputs for oidc-db module

output "oidc_db_id" {
  value       = azurerm_user_assigned_identity.db_identity.id
  description = "OIDC identity id"
  sensitive   = false
}

output "oidc_db_client_id" {
  value       = azurerm_user_assigned_identity.db_identity.client_id
  description = "OIDC cidentity client id"
  sensitive   = false
}