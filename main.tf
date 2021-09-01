provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "scale-set-resources"
  location = "UK West"
}

resource "azurerm_virtual_network" "uk" {
  name                = "uk-network"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "internal-uk" {
  name                 = "internal-uk"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.uk.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_linux_virtual_machine_scale_set" "uk_vmss" {
  name                = "uk-vmss"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_virtual_network.uk.location
  sku                 = "Standard_B1ms"
  instances           = 1
  admin_username      = "pranay"

  admin_ssh_key {
    username   = "pranay"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "uk-network"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.internal-uk.id
    }
  }
   

}

resource "azurerm_monitor_autoscale_setting" "uk-auto-scale-set" {
  name                = "uk-auto-scale-set"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_virtual_network.uk.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.uk_vmss.id

  profile {
    name = "uphours"

    capacity {
      default = 1
      minimum = 1
      maximum = 3
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.uk_vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
        metric_namespace   = "microsoft.compute/virtualmachinescalesets"
        dimensions {
          name     = "AppName"
          operator = "Equals"
          values   = ["App1"]
        }
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.uk_vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
    recurrence {
      timezone = "Pacific Standard Time"
      days    = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
      hours      = [9]
      minutes = [0]
    }
  }
  profile {
    name = "downhours"

    capacity {
      default = 0
      minimum = 0
      maximum = 0
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.uk_vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
    recurrence {
      timezone = "Pacific Standard Time"
      days    = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
      hours      = [17]
      minutes = [0]
    }
  }
}


resource "azurerm_virtual_network" "france" {
  name                = "france-network"
  resource_group_name = azurerm_resource_group.example.name
  location            = "France Central"
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "internal-france" {
  name                 = "internal-france"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.france.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_linux_virtual_machine_scale_set" "france_vmss" {
  name                = "france-vmss"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_virtual_network.france.location
  sku                 = "Standard_B1ms"
  instances           = 1
  admin_username      = "pranay"

  admin_ssh_key {
    username   = "pranay"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "france-network"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.internal-france.id
    }
  }
   

}


resource "azurerm_monitor_autoscale_setting" "france-auto-scale-set" {
  name                = "france-auto-scale-set"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_virtual_network.france.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.france_vmss.id

   profile {
    name = "uphours"

    capacity {
      default = 1
      minimum = 1
      maximum = 3
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.france_vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
        metric_namespace   = "microsoft.compute/virtualmachinescalesets"
        dimensions {
          name     = "AppName"
          operator = "Equals"
          values   = ["App1"]
        }
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.france_vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
    recurrence {
      timezone = "GMT Standard Time"
      days    = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
      hours      = [10]
      minutes = [0]
    }
  }
  profile {
    name = "downhours"

    capacity {
      default = 0
      minimum = 0
      maximum = 0
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.france_vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
    recurrence {
      timezone = "GMT Standard Time"
      days    = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
      hours      = [15] 
      minutes = [0]
    }
  }
}


resource "azurerm_virtual_network" "india" {
  name                = "india-network"
  resource_group_name = azurerm_resource_group.example.name
  location            = "Central India"
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "internal-india" {
  name                 = "internal-india"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.india.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_linux_virtual_machine_scale_set" "india_vmss" {
  name                = "india-vmss"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_virtual_network.india.location
  sku                 = "Standard_B1ms"
  instances           = 1
  admin_username      = "pranay"

  admin_ssh_key {
    username   = "pranay"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "india-network"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.internal-india.id
    }
  }
   

}


resource "azurerm_monitor_autoscale_setting" "india-auto-scale-set" {
  name                = "india-auto-scale-set"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_virtual_network.india.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.india_vmss.id

   profile {
    name = "uphours"

    capacity {
      default = 1
      minimum = 1
      maximum = 3
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.india_vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
        metric_namespace   = "microsoft.compute/virtualmachinescalesets"
        dimensions {
          name     = "AppName"
          operator = "Equals"
          values   = ["App1"]
        }
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.india_vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
    recurrence {
      timezone = "India Standard Time"
      days    = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
      hours      = [2]
      minutes = [30]
    }
  }
  profile {
    name = "downhours"

    capacity {
      default = 0
      minimum = 0
      maximum = 0
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.india_vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
    recurrence {
      timezone = "Pacific Standard Time"
      days    = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
      hours      = [22]
      minutes = [30]
    }
  }
}
  
