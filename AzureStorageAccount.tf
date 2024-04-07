resource "azurerm_resource_group" "demo" {
  name     = "example-resources"
  location = "CentralIndia"
}

resource "azurerm_storage_account" "StorageAccountDemo" {
  name                     = "sate"
  resource_group_name      = azurerm_resource_group.demo.name
  location                 = azurerm_resource_group.demo.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_monitor_action_group" "ActionGroupDemo" {
  name                = "example-action-group"
  resource_group_name = azurerm_resource_group.demo.name
  short_name          = "ex-action-grp"
  email_receiver {
    name          = "email"
    email_address = "gauravkumar.pandey@bluepi.in"
  }
}

resource "azurerm_monitor_metric_alert" "storage_account_alert" {
  name                = "storage-account-capacity-alert"
  resource_group_name = azurerm_resource_group.demo.name
  scopes              = [azurerm_storage_account.StorageAccountDemo.id]

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "BlobCapacity"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 1
    time_aggregation = "Average"
  }

  action {
    action_group_id = azurerm_monitor_action_group.ActionGroupDemo.id
  }

  description = "Alert triggered when Blob capacity exceeds 1%"
}
