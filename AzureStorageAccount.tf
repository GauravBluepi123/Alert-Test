resource "azurerm_resource_group" "demo" {
  name     = "example-resources"
  location = "CentralIndia"
}

##  Demo now
resource "azurerm_storage_account" "StorageAccountDemo" {
  name                     = "sate"
  resource_group_name      = azurerm_resource_group.demo.name
  location                 = azurerm_resource_group.demo.location
  account_tier             = "Standard"
  account_replication_type = "GRS"


}
