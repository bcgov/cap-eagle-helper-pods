provider "azurerm" {
  version = "~> 1.33"
}

resource "azurerm_resource_group" "cap-rg" {
  name     = "cap-rg"
  location = "canadacentral"
}

resource "azurerm_storage_account" "storage" {
  name                     = "bcgovcapstorage"
  resource_group_name      = "${azurerm_resource_group.cap-rg.name}"
  location                 = "${azurerm_resource_group.cap-rg.location}"
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    project = "cap"
    environment = "poc"
  }
}

output "primary_access_key" {
  value = "${azurerm_storage_account.storage.primary_access_key}"
}