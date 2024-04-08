data "azurerm_resource_group" "storage_account_rg" {
  name = azurerm_storage_account.StorageAccountDemo.resource_group_name
}


resource "azurerm_virtual_network" "example" {
  name                = "my-virtual-network"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.storage_account_rg.location
  resource_group_name = data.azurerm_resource_group.storage_account_rg.name
}

# Define the subnet within the virtual network
resource "azurerm_subnet" "example" {
  name                 = "my-subnet"
  virtual_network_name = azurerm_virtual_network.example.name
  resource_group_name  = data.azurerm_resource_group.storage_account_rg.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Define the public IP address
resource "azurerm_public_ip" "example" {
  name                = "my-public-ip"
  location            = data.azurerm_resource_group.storage_account_rg.location
  resource_group_name = data.azurerm_resource_group.storage_account_rg.name
  allocation_method   = "Dynamic"
}

# Define the network interface
resource "azurerm_network_interface" "example" {
  name                = "my-network-interface"
  location            = data.azurerm_resource_group.storage_account_rg.location
  resource_group_name = data.azurerm_resource_group.storage_account_rg.name

  ip_configuration {
    name                          = "my-ip-config"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
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

resource "azurerm_monitor_action_group" "vm_alerts_action_group" {
  name                = "vm-alerts-action-group"
  resource_group_name = data.azurerm_resource_group.storage_account_rg.name
  short_name          = "vmalerts"

  email_receiver {
    name          = "email"
    email_address = "gauravkumar.pandey@bluepi.in"
  }
}

resource "azurerm_monitor_metric_alert" "vm_cpu_alert" {
  name                = "vm-cpu-usage-alert"
  resource_group_name = data.azurerm_resource_group.storage_account_rg.name
  scopes              = [azurerm_virtual_machine.example.id]

  criteria {
    metric_namespace = "microsoft.compute/virtualmachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 90
  }

  action {
    action_group_id = azurerm_monitor_action_group.vm_alerts_action_group.id
  }

  description = "Alert triggered when VM CPU usage exceeds 90%"
  window_size = "PT5M"
}

resource "azurerm_monitor_metric_alert" "vm_memory_alert" {
  name                = "vm-memory-usage-alert"
  resource_group_name = data.azurerm_resource_group.storage_account_rg.name
  scopes              = [azurerm_virtual_machine.example.id]

  criteria {
    metric_namespace = "microsoft.compute/virtualmachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 20
  }
}

  action {
    action_group_id = azurerm_monitor_action_group.vm_alerts_action_group.id
  }

  description = "Alert triggered when VM memory usage exceeds 80%"
  window_size = "PT5M"