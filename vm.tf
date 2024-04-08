data "azurerm_resource_group" "storage_account_rg" {
  name = azurerm_storage_account.StorageAccountDemo.resource_group_name
}

resource "azurerm_virtual_machine" "example" {
  name                  = "my-vm"
  location              = data.azurerm_resource_group.storage_account_rg.location
  resource_group_name   = data.azurerm_resource_group.storage_account_rg.name
  vm_size               = "Standard_DS1_v2"
  network_interface_ids = [azurerm_network_interface.example.id]

  storage_os_disk {
    name              = "my-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-datacenter"
    version   = "latest"
  }

  os_profile {
    computer_name  = "my-vm"
    admin_username = "azureuser"
    admin_password = "Password123!"  # Replace with your desired password
  }

  os_profile_windows_config {
    enable_automatic_upgrades = true
  }
}
