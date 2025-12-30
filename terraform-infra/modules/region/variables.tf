# Variables.tf for region
variable "location" {}
variable "resource_group_name" {}
variable "is_primary" { default = false }
variable "sql_admin_username" {}
variable "db_name" {}
variable "fog_db_name" {}