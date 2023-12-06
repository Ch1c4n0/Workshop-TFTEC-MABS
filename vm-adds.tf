resource "azurerm_public_ip" "my-public-ip" {
  name                = "Public-ip-${var.name-vm1}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location1
  allocation_method   = "Static"

  tags = {
    environment = "Testing"
  }
}

resource "azurerm_network_interface" "mynetworkinterface" {
  name                = "network-interface-${var.name-vm1}"
  location            = var.location1
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal-${var.name-vm1}"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ip_dns_adds

    public_ip_address_id = azurerm_public_ip.my-public-ip.id
  }
}

# Windows 11 Virtual Machine
resource "azurerm_windows_virtual_machine" "myvirtualmachine" {
  name                = "vm-${var.name-vm1}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location1
  size                = var.my_virtual_machine_size
  admin_username      = var.win_username
  admin_password      = var.win_userpass
  network_interface_ids = [
    azurerm_network_interface.mynetworkinterface.id,
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


}
# Security Group - allowing RDP Connection
resource "azurerm_network_security_group" "sg-rdp-connection" {
  name                = "allowrdpconnection-${var.name-vm1}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "rdpport"
    priority                   = 100
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
}


# Associate security group with network interface
resource "azurerm_network_interface_security_group_association" "my_association" {
  network_interface_id      = azurerm_network_interface.mynetworkinterface.id
  network_security_group_id = azurerm_network_security_group.sg-rdp-connection.id
}

#Install Active Directory on the DC01 VM
resource "azurerm_virtual_machine_extension" "install_ad" {
  name = "install_ad"
  #  resource_group_name  = azurerm_resource_group.main.name
  virtual_machine_id   = azurerm_windows_virtual_machine.myvirtualmachine.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  protected_settings = <<SETTINGS
  {    
    "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.ADDS.rendered)}')) | Out-File -filepath ADDS.ps1\" && powershell -ExecutionPolicy Unrestricted -File ADDS.ps1 -Domain_DNSName ${data.template_file.ADDS.vars.Domain_DNSName} -Domain_NETBIOSName ${data.template_file.ADDS.vars.Domain_NETBIOSName} -SafeModeAdministratorPassword ${data.template_file.ADDS.vars.SafeModeAdministratorPassword}"
  }
  SETTINGS
}

#Variable input for the ADDS.ps1 script
data "template_file" "ADDS_install" {
  template = file("ADDS.ps1")
  vars = {
    Domain_DNSName                = "${var.Domain_DNSName}"
    Domain_NETBIOSName            = "${var.netbios_name}"
    SafeModeAdministratorPassword = "${var.SafeModeAdministratorPassword}"
  }
}