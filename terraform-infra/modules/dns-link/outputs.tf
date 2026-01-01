# Outputs for dns-link module

output "dns_zone_id" {
  value       = azurerm_private_dns_zone.sql_dns.id
  description = "DNS zone id"
  sensitive   = false
}