resource "time_sleep" "wait_120_seconds" {
  depends_on = [azurerm_virtual_machine_extension.install_ad]

  create_duration = "180s"
}