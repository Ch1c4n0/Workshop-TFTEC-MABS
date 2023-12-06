resource "azurerm_public_ip" "my-public-ip4" {
  name                = "Public-ip-${var.name-vm4}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location2
  allocation_method   = "Static"

  tags = {
    environment = "Testing"
  }

  depends_on = [
    azurerm_virtual_network_dns_servers.dns2,
    azurerm_windows_virtual_machine.myvirtualmachine3,
    time_sleep.wait_120_seconds
  ]

}

resource "azurerm_network_interface" "mynetworkinterface4" {
  name                = "network-interface-${var.name-vm4}"
  location            = var.location2
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal-${var.name-vm4}"
    subnet_id                     = azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Dynamic"

    public_ip_address_id = azurerm_public_ip.my-public-ip4.id
  }

  depends_on = [
    azurerm_virtual_network_dns_servers.dns2,
    azurerm_windows_virtual_machine.myvirtualmachine3,
    time_sleep.wait_120_seconds
  ]

}


resource "azurerm_windows_virtual_machine" "myvirtualmachine4" {
  name                = "vm-${var.name-vm4}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location2
  size                = var.my_virtual_machine_size
  admin_username      = var.win_username
  admin_password      = var.win_userpass
  network_interface_ids = [
    azurerm_network_interface.mynetworkinterface4.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = "sql2022-ws2022"
    sku       = "sqldev-gen2"
    version   = "latest"
  }



  depends_on = [
    azurerm_virtual_network_dns_servers.dns2,
    azurerm_windows_virtual_machine.myvirtualmachine3,
    time_sleep.wait_120_seconds
  ]

}


# Create managed disk for data of SQL
resource "azurerm_managed_disk" "sqlha_data" {
  name                 = "disk-data"
  location             = var.location2
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 8
}

# Create managed disk attachment for SQL data on LUN-0
resource "azurerm_virtual_machine_data_disk_attachment" "sqlha_data" {
  managed_disk_id    = azurerm_managed_disk.sqlha_data.id
  virtual_machine_id = azurerm_windows_virtual_machine.myvirtualmachine4.id
  lun                = "1"
  caching            = "ReadWrite"
}

resource "azurerm_managed_disk" "sqlha_log" {
  name                 = "disk-log"
  location             = var.location2
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 8
}

# Create managed disk attachment for SQL log on LUN-1
resource "azurerm_virtual_machine_data_disk_attachment" "sqlha_log" {
  managed_disk_id    = azurerm_managed_disk.sqlha_log.id
  virtual_machine_id = azurerm_windows_virtual_machine.myvirtualmachine4.id
  lun                = "2"
  caching            = "ReadWrite"
}


# Create managed disk for temp of SQL
resource "azurerm_managed_disk" "sqlha_temp" {
  name                 = "disk_temp"
  location             = var.location2
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 8

}

# Create managed disk attachment for SQL temp on LUN-2
resource "azurerm_virtual_machine_data_disk_attachment" "sqlha_temp" {
  managed_disk_id    = azurerm_managed_disk.sqlha_temp.id
  virtual_machine_id = azurerm_windows_virtual_machine.myvirtualmachine4.id
  lun                = "3"
  caching            = "ReadWrite"
}


resource "azurerm_mssql_virtual_machine" "sqlha" {


  virtual_machine_id               = azurerm_windows_virtual_machine.myvirtualmachine4.id
  sql_license_type                 = "PAYG"
  sql_connectivity_port            = 1433
  sql_connectivity_type            = "PRIVATE"
  sql_connectivity_update_username = var.sql_username
  sql_connectivity_update_password = var.sql_userpass




  storage_configuration {
    disk_type             = "NEW"
    storage_workload_type = "GENERAL"
    data_settings {
      default_file_path = "K:\\Data"
      luns              = [azurerm_virtual_machine_data_disk_attachment.sqlha_data.lun]
    }

    log_settings {
      default_file_path = "L:\\Logs"
      luns              = [azurerm_virtual_machine_data_disk_attachment.sqlha_log.lun]
    }

    temp_db_settings {
      default_file_path = "T:\\Temp"
      luns              = [azurerm_virtual_machine_data_disk_attachment.sqlha_temp.lun]
    }
  }


}




# Security Group - allowing RDP Connection
resource "azurerm_network_security_group" "sg-rdp-connection4" {
  name                = "allowrdpconnection-${var.name-vm4}"
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



  tags = {
    environment = "Testing"
  }

  depends_on = [
    azurerm_virtual_network_dns_servers.dns2,
    azurerm_windows_virtual_machine.myvirtualmachine3,
    time_sleep.wait_120_seconds
  ]

}


# Associate security group with network interface
resource "azurerm_network_interface_security_group_association" "my_association4" {
  network_interface_id      = azurerm_network_interface.mynetworkinterface4.id
  network_security_group_id = azurerm_network_security_group.sg-rdp-connection4.id
}


resource "azurerm_virtual_machine_extension" "join-domain1" {
  name                       = "join-domain1"
  virtual_machine_id         = azurerm_windows_virtual_machine.myvirtualmachine4.id
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
    azurerm_windows_virtual_machine.myvirtualmachine3,
    time_sleep.wait_120_seconds
  ]




}