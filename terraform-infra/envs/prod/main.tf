# Create primary resource group
module "rg-primary" {
  source              = "../../modules/resource-group"
  resource_group_name = var.primary_rg_name
  location            = var.primary_location
}

# Create secondary resource group
module "rg-secondary" {
  source              = "../../modules/resource-group"
  resource_group_name = var.secondary_rg_name
  location            = var.secondary_location
}

# Create oidc identity for github actions
module "oidc_github" {
  location         = var.primary_location
  source           = "../../modules/oidc-github"
  primary_rg_name  = var.primary_rg_name
  primary_rg_id    = module.rg-primary.rg_id
  secondary_rg_id  = module.rg-secondary.rg_id
  github_org_name  = var.github_org_name
  github_repo_name = var.github_repo_name

  depends_on = [
    module.rg-primary,
    module.rg-secondary
  ]

}

# Create oidc identity for db
module "oidc_db" {
  location        = var.primary_location
  source          = "../../modules/oidc-db"
  primary_rg_name = var.primary_rg_name
}

# Create db and failover group
module "sql" {
  source              = "../../modules/sql-geo"
  primary_server_id   = module.primary.sql_server_id
  secondary_server_id = module.secondary.sql_server_id
  db_name             = var.db_name
}

# Create dns-link between dns-zone and vnets
module "dns-link" {
  source              = "../../modules/dns-link"
  primary_vnet_id     = module.primary.vnet_id
  secondary_vnet_id   = module.secondary.vnet_id
  resource_group_name = var.primary_rg_name

  depends_on = [
    module.rg-primary
  ]

}

# Create resources in the primary region/resource group
module "primary" {
  source              = "../../modules/region"
  location            = var.primary_location
  is_primary          = true
  resource_group_name = var.primary_rg_name
  db_name             = var.db_name
  sql_admin_username  = var.sql_admin_username
  fog_db_name         = module.sql.fog_db_name
  dns_zone_id         = module.dns-link.dns_zone_id
  oidc_db_id          = module.oidc_db.oidc_db_id
  oidc_db_client_id   = module.oidc_db.oidc_db_client_id

  depends_on = [
    module.rg-primary
  ]

}

# Create resources in the secondary region/resource group
module "secondary" {
  source              = "../../modules/region"
  location            = var.secondary_location
  is_primary          = false
  resource_group_name = var.secondary_rg_name
  db_name             = var.db_name
  sql_admin_username  = var.sql_admin_username
  fog_db_name         = module.sql.fog_db_name
  dns_zone_id         = module.dns-link.dns_zone_id
  oidc_db_id          = module.oidc_db.oidc_db_id
  oidc_db_client_id   = module.oidc_db.oidc_db_client_id

  depends_on = [
    module.rg-secondary
  ]

}

# Create azure frontdoor ( not created as the current free-trail subsription didn't allow it)
# module "frontdoor" {
#   source                  = "../../modules/frontdoor"
#   primary_app_hostname    = module.primary.app_hostname
#   secondary_app_hostname  = module.secondary.app_hostname
#   resource_group_name     = var.primary_rg_name

#   depends_on = [
#     module.primary
#   ]

# }

# Create traffic manager and link the apps
module "traffic-manager" {
  source                    = "../../modules/traffic-manager"
  primary_app_service_id    = module.primary.app_id
  secondary_app_service_id  = module.secondary.app_id
  resource_group_name       = var.primary_rg_name

  depends_on = [
    module.primary,
    module.secondary
  ]

}

# Create vnet-peering between vnet1 to vent2 and vice-versa
module "vnet-peering" {
  source              = "../../modules/vnet-peering"
  primary_rg_name     = var.primary_rg_name
  secondary_rg_name   = var.secondary_rg_name
  primary_vnet_name   = module.primary.vnet_name
  secondary_vnet_name = module.secondary.vnet_name
  primary_vnet_id     = module.primary.vnet_id
  secondary_vnet_id   = module.secondary.vnet_id

  depends_on = [
    module.primary,
    module.secondary
  ]

}

# Create jump-host-vm in the primary vnet
module "jump-vm" {
  source = "../../modules/jump-vm"
  location = var.primary_location
  resource_group_name = var.primary_rg_name

  depends_on = [
    module.primary
  ]

}
