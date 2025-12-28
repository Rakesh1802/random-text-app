variable "location" {
  type    = string
  default = "Central India"
}

variable "resource_group_name" {
  type    = string
  default = "rg-web-sql-demo"
}

variable "sql_admin_username" {
  type    = string
  default = "sqladmin"
}

# variable "sql_admin_password" {
#   type      = string
#   sensitive = true
# }

variable "sql_db_name" {
  type    = string
  default = "appdb"
}

