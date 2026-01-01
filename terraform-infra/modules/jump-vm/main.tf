# Create a subnet for JUMP vm in primary vnet
resource "azurerm_subnet" "jump" {
  name                 = "snet-jump"
  resource_group_name  = var.resource_group_name
  virtual_network_name = "vnet-${var.location}"
  address_prefixes     = ["10.0.0.96/27"]
}

# NSG to allow access my ip
resource "azurerm_network_security_group" "jump_nsg" {
  name                = "nsg-jump"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-SSH-From-My-IP"
    priority                   = 100
    direction                  = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "22"
    source_address_prefix       = "157.50.102.255/32"
    destination_address_prefix  = "*"
  }
}

# Association
resource "azurerm_subnet_network_security_group_association" "jump_assoc" {
  subnet_id                 = azurerm_subnet.jump.id
  network_security_group_id = azurerm_network_security_group.jump_nsg.id
}

# Public ip
resource "azurerm_public_ip" "jump_pip" {
  name                = "pip-jump"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Network interface
resource "azurerm_network_interface" "jump_nic" {
  name                = "nic-jump"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.jump.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jump_pip.id
  }
}

# Jump VM
resource "azurerm_linux_virtual_machine" "jump" {
  name                = "vm-jump"
  location            = var.location
  resource_group_name = var.resource_group_name
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