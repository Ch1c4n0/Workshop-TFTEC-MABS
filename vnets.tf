resource "azurerm_virtual_network" "vnet1" {
  name                = "vnet-${var.vnet1-name}"
  address_space       = ["10.10.0.0/16"]
  location            = var.vnet1-location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet1" {
  name                 = "sub-${var.vnet1-name}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_virtual_network_dns_servers" "dns1" {
  virtual_network_id = azurerm_virtual_network.vnet1.id
  dns_servers        = [var.ip_dns_adds]
  depends_on = [
    azurerm_windows_virtual_machine.myvirtualmachine
  ]
}


resource "azurerm_virtual_network" "vnet2" {
  name                = "vnet-${var.vnet2-name}"
  address_space       = ["10.20.0.0/16"]
  location            = var.vnet2-location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet2" {
  name                 = "vnet-${var.vnet2-name}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet2.name
  address_prefixes     = ["10.20.1.0/24"]
}

resource "azurerm_virtual_network_dns_servers" "dns2" {
  virtual_network_id = azurerm_virtual_network.vnet2.id
  dns_servers        = [var.ip_dns_adds]
  depends_on = [
    azurerm_windows_virtual_machine.myvirtualmachine
  ]
}


