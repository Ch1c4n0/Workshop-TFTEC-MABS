resource "azurerm_resource_group" "rg" {
  name     = lower("rg-${var.nameresourcegroup}")
  location = var.location1
}