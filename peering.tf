resource "azurerm_virtual_network_peering" "peer-vnet1" {
  name                      = "${var.vnet1-name}to${var.vnet2-name}"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet1.name
  remote_virtual_network_id = azurerm_virtual_network.vnet2.id
}

resource "azurerm_virtual_network_peering" "peer-vnet2" {
  name                      = "${var.vnet2-name}to${var.vnet1-name}"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet2.name
  remote_virtual_network_id = azurerm_virtual_network.vnet1.id
}