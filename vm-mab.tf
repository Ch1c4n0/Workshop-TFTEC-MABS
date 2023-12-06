resource "azurerm_public_ip" "my-public-ip3" {
  name                = "Public-ip-${var.name-vm3}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location2
  allocation_method   = "Static"

  tags = {
    environment = "Testing"
  }

  depends_on = [
    azurerm_virtual_network_dns_servers.dns2,
    azurerm_windows_virtual_machine.myvirtualmachine2,
    time_sleep.wait_120_seconds
  ]
}

resource "azurerm_network_interface" "mynetworkinterface3" {
  name                = "network-interface-${var.name-vm3}"
  location            = var.location2
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal-${var.name-vm3}"
    subnet_id                     = azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Dynamic"

    public_ip_address_id = azurerm_public_ip.my-public-ip3.id
  }

  depends_on = [
    azurerm_virtual_network_dns_servers.dns2,
    azurerm_windows_virtual_machine.myvirtualmachine2,
    time_sleep.wait_120_seconds
  ]
}

# Windows 11 Virtual Machine
resource "azurerm_windows_virtual_machine" "myvirtualmachine3" {
  name                = "vm-${var.name-vm3}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location2
  size                = var.my_virtual_machine_size
  admin_username      = var.win_username
  admin_password      = var.win_userpass
  network_interface_ids = [
    azurerm_network_interface.mynetworkinterface3.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter"
    version   = "latest"
  }

  depends_on = [
    azurerm_virtual_network_dns_servers.dns2,
    azurerm_windows_virtual_machine.myvirtualmachine2,
    time_sleep.wait_120_seconds
  ]
}


# Security Group - allowing RDP Connection
resource "azurerm_network_security_group" "sg-rdp-connection3" {
  name                = "allowrdpconnection-${var.name-vm3}"
  location            = var.location2
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "rdpport"
    priority                   = 119
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  security_rule {
    name                       = "HTTPport"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  tags = {
    environment = "Testing"
  }
  depends_on = [
    azurerm_virtual_network_dns_servers.dns2,
    azurerm_windows_virtual_machine.myvirtualmachine2,
    time_sleep.wait_120_seconds
  ]
}


# Associate security group with network interface
resource "azurerm_network_interface_security_group_association" "my_association3" {
  network_interface_id      = azurerm_network_interface.mynetworkinterface3.id
  network_security_group_id = azurerm_network_security_group.sg-rdp-connection3.id
}



resource "azurerm_virtual_machine_extension" "join-domain2" {
  name                       = "join-domain2"
  virtual_machine_id         = azurerm_windows_virtual_machine.myvirtualmachine3.id
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  # What the settings mean: https://docs.microsoft.com/en-us/windows/desktop/api/lmjoin/nf-lmjoin-netjoindomain

  settings           = <<SETTINGS
    {
        "Name": "${var.Domain_DNSName}",
        "OUPath": "",
        "User": "${var.Domain_DNSName}\\${var.win_username}",
        "Restart": "true",
        "Options": "3"
    }
SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
      "Password": "${var.win_userpass}"
    }
  PROTECTED_SETTINGS

  depends_on = [
    azurerm_windows_virtual_machine.myvirtualmachine2,
    time_sleep.wait_120_seconds
  ]

}