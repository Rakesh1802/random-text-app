# this is the main.terraform

module "sql" {
  source              = "../../modules/sql-geo"
  primary_server_id   = module.central.sql_server_id
  secondary_server_id = module.eastasia.sql_server_id
  db_name             = var.db_name
}

module "central" {
  source              = "../../modules/region"
  location            = "centralindia"
  is_primary          = true
  resource_group_name = "rg-web-sql-demo-primary"
  db_name             = var.db_name
  sql_admin_username  = var.sql_admin_username
  fog_db_name         = module.sql.fog_db_name
}

module "eastasia" {
  source              = "../../modules/region"
  location            = "eastasia"
  is_primary          = false
  resource_group_name = "rg-web-sql-demo-secondary"
  db_name             = var.db_name
  sql_admin_username  = var.sql_admin_username
  fog_db_name         = module.sql.fog_db_name
}

# module "frontdoor" {
#   source                  = "../../modules/frontdoor"
#   primary_app_hostname    = module.central.app_hostname
#   secondary_app_hostname  = module.eastasia.app_hostname
#   resource_group_name     = "rg-web-sql-demo-primary"

#   depends_on = [
#     module.central
#   ]

# }

module "traffic-manager" {
  source                  = "../../modules/traffic-manager"
  primary_app_service_id          = module.central.app_id
  secondary_app_service_id        = module.eastasia.app_id
  resource_group_name     = "rg-web-sql-demo-primary"

  depends_on = [
    module.central
  ]

}

module "jump-vm" {
  source = "../../modules/jump-vm"
  location = "centralindia"
  resource_group_name = "rg-web-sql-demo-primary"

  depends_on = [
    module.central
  ]

}
