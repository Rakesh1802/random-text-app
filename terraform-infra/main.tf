resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "appsvc" {
  name                 = "snet-appservice"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "appsvc-delegation"

    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }
}

resource "azurerm_subnet" "private" {
  name                 = "snet-private-endpoints"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]

  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_service_plan" "asp" {
  name                = "asp-web-${random_integer.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "B1"
  worker_count        = 2
}

# Reference the existing Key Vault
data "azurerm_key_vault" "existing" {
  name                 = "my-key-vault-101"
  resource_group_name  = "my-key-vault-rg"
}

data "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  key_vault_id = data.azurerm_key_vault.existing.id
}

resource "azurerm_linux_web_app" "web" {
  name                = "webapp-${random_integer.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.asp.id

  https_only = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      node_version = "20-lts"
    }
    always_on = true
  }

  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE = "1",
    DB_NAME = var.sql_db_name,
    DB_USER = var.sql_admin_username,
    DB_PASSWORD = data.azurerm_key_vault_secret.db_password.value
    DB_SERVER = azurerm_mssql_server.sql_server.fully_qualified_domain_name
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
  app_service_id = azurerm_linux_web_app.web.id
  subnet_id     = azurerm_subnet.appsvc.id
}

resource "azurerm_mssql_server" "sql_server" {
  name                         = "sqlserver-${random_integer.suffix.result}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = data.azurerm_key_vault_secret.db_password.value

  public_network_access_enabled = false
}

resource "azurerm_mssql_database" "sql_db" {
  name      = var.sql_db_name
  server_id = azurerm_mssql_server.sql_server.id
  sku_name  = "Basic"
}

resource "azurerm_private_endpoint" "sql_pe" {
  name                = "pe-sql"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.private.id

  private_service_connection {
    name                           = "sql-connection"
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_zone" "sql_dns" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
  name                  = "sql-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.sql_dns.name
  virtual_network_id   = azurerm_virtual_network.vnet.id
}

# data "azurerm_client_config" "current" {}

# resource "null_resource" "sql_permissions" {
#   depends_on = [
#     azurerm_mssql_server.sql_server
#   ]

#   provisioner "local-exec" {
#     command = <<EOT
# sqlcmd -S ${azurerm_mssql_server.sql_server.fully_qualified_domain_name} -d ${azurerm_mssql_database.sql_db.name} -G -Q "IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'app-prod') BEGIN CREATE USER [app-prod] FROM EXTERNAL PROVIDER; END; ALTER ROLE db_datareader ADD MEMBER [app-prod]; ALTER ROLE db_datawriter ADD MEMBER [app-prod];"
# EOT
#   }
# }

# Jump host stuff
resource "azurerm_subnet" "jump" {
  name                 = "snet-jump"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_network_security_group" "jump_nsg" {
  name                = "nsg-jump"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-SSH-From-My-IP"
    priority                   = 100
    direction                  = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "22"
    source_address_prefix       = "157.50.100.107/32"
    destination_address_prefix  = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "jump_assoc" {
  subnet_id                 = azurerm_subnet.jump.id
  network_security_group_id = azurerm_network_security_group.jump_nsg.id
}

resource "azurerm_public_ip" "jump_pip" {
  name                = "pip-jump"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "jump_nic" {
  name                = "nic-jump"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.jump.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jump_pip.id
  }
}

resource "azurerm_linux_virtual_machine" "jump" {
  name                = "vm-jump"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = "Standard_D2ls_v6"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.jump_nic.id
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("C:/Users/rakes/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}


