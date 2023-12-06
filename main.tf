terraform {
  backend "azurerm" {
    resource_group_name  = "Nome do Resource Group"
    storage_account_name = "Nome do Storage Account"
    container_name       = "Nome do Container"
    key                  = "Chave do Storage Account"
  }
}



provider "azurerm" {
  # Configuration options
  features {

  }
}