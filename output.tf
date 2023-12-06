output "public_ip_address_vm-adds" {
  value = azurerm_windows_virtual_machine.myvirtualmachine.public_ip_address
}


output "public_ip_address_vm-WEB" {
  value = azurerm_windows_virtual_machine.myvirtualmachine2.public_ip_address
}


output "public_ip_address_vm-MAB" {
  value = azurerm_windows_virtual_machine.myvirtualmachine3.public_ip_address
}

output "public_ip_address_vm-SQL" {
  value = azurerm_windows_virtual_machine.myvirtualmachine4.public_ip_address
}


