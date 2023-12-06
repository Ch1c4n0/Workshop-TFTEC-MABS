resource "azurerm_recovery_services_vault" "recvalt" {
  name                = "recovery-vault-mab"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  soft_delete_enabled = false
  storage_mode_type   = "LocallyRedundant"

  depends_on = [
    azurerm_virtual_network_dns_servers.dns2,
    azurerm_windows_virtual_machine.myvirtualmachine4,
    time_sleep.wait_120_seconds
  ]
}