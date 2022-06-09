# Configure the Microsoft Azure Provider
provider "azurerm" {
  version = "=1.44.0"
    subscription_id = "${var.subscriptionid}" 
    client_id       = "${var.clientid}"
    client_secret   = "${var.clientsecret}"
    tenant_id       = "${var.tenantid}"
	skip_provider_registration = true
}

terraform {
  backend "azurerm" {
    resource_group_name   = "devops-interview-gauntlet-x-mkhan"
    storage_account_name  = "terraformtf"
    container_name        = "tfstate"
    key                   = "terraform.tfstate"
 }
}


# Create New Vnet

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.vnet_name1}"
  location 	      = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  address_space       = ["${var.vnet_add1}"]
}

# Create New Subnets

resource "azurerm_subnet" "sub1" {
  name           = "${var.subnet1}"
  resource_group_name = "${var.resource_group_name}"
  virtual_network_name  = "${azurerm_virtual_network.vnet.name}"
  address_prefix = "${var.sub1_add}"
depends_on = ["azurerm_virtual_network.vnet"]
  }
  
resource "azurerm_subnet" "sub2" {
  name           = "${var.subnet2}"
  resource_group_name = "${var.resource_group_name}"
  virtual_network_name  = "${azurerm_virtual_network.vnet.name}"
  address_prefix = "${var.sub2_add}"
  delegation {
    name = "delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
depends_on = ["azurerm_virtual_network.vnet"]
  }


resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "${var.nsg_name1}"
    location            = "${var.location}"
    resource_group_name = "${var.resource_group_name}"
    
    security_rule {
        name                       = "RDPInboundPort"
        priority                   = 1000
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "*"
        destination_address_prefix = "10.25.0.0/16"
    }
    security_rule {
        name                       = "CustomInternet_TCP"
        priority                   = 1010
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range    = "443"
        source_address_prefix      = "Internet"
        destination_address_prefix = "10.25.0.0/16"
    }

depends_on = ["azurerm_subnet.sub1"]
}

resource "azurerm_public_ip" "public_ip" {
  count               = var.node_count
  name                = "${var.vm_name}${count.index+1}-PIP"
  location 	      = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  allocation_method   = "Dynamic"
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
    count               = var.node_count
    name                      = "${var.vm_name}${count.index+1}-NIC"
    location                  = "${var.location}"
    resource_group_name       = "${var.resource_group_name}"
    network_security_group_id = azurerm_network_security_group.myterraformnsg.id


    ip_configuration {
        name                          = "ipconfig-${var.vm_name}${count.index+1}"
        subnet_id                     = "${azurerm_subnet.sub1.id}"
		private_ip_address_allocation = "static"
        private_ip_address = "${cidrhost("${var.sub1_add}",  4+count.index)}"
		public_ip_address_id = azurerm_public_ip.public_ip[count.index].id

    }
depends_on = ["azurerm_subnet.sub1"]
}

resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${var.resource_group_name}"
    }
    
    byte_length = 8
}

resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = "${var.resource_group_name}"
    location                    = "${var.location}"
    account_replication_type    = "LRS"
    account_tier                = "Standard"
}

resource "azurerm_availability_set" "avset" {
  name                        = "${var.vm_name}-avset"
  resource_group_name         = "${var.resource_group_name}"
  location                    = "${var.location}"
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true

}


# Create virtual machine
resource "azurerm_virtual_machine" "myterraformvm" {
    count               = var.node_count
    name                  = "${var.vm_name}${count.index+1}"
    location              = "${var.location}"
    resource_group_name   = "${var.resource_group_name}"
    network_interface_ids = [azurerm_network_interface.myterraformnic[count.index].id]
    vm_size               = "${var.vm_size}"
    availability_set_id   = "${azurerm_availability_set.avset.id}"
    delete_os_disk_on_termination    = true
    delete_data_disks_on_termination = true


    storage_os_disk {
        name              = "${var.vm_name}${count.index+1}_OS_disk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }


    os_profile {
        computer_name  = "${var.vm_name}${count.index+1}"
        admin_username = "azureuser"
		admin_password = "Wind0wsazure"
    }

    os_profile_windows_config {
        provision_vm_agent = true
		winrm {
            protocol = "http"
            certificate_url = ""
        }
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }

}

locals {
  number_of_disks = 1
}


resource "azurerm_virtual_machine_extension" "vm_extension_install_iis" {
  count               = var.node_count
  name                       = "vm_extension_install_iis"
  virtual_machine_id         = azurerm_virtual_machine.myterraformvm[count.index].id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.8"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
	"fileUris": ["https://raw.githubusercontent.com/nishantswo/kforce/main/terraform/cats.jpg", "https://raw.githubusercontent.com/nishantswo/kforce/main/terraform/index.html", "https://raw.githubusercontent.com/nishantswo/kforce/main/terraform/script.ps1"],
    "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File script.ps1"
    }
SETTINGS 
depends_on = ["azurerm_virtual_machine.myterraformvm"]
}


# Generate a random integer to create a globally unique name
resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

# Create the Linux App Service Plan
resource "azurerm_app_service_plan" "appserviceplan" {
  name                = "webapp-asp-${random_integer.ri.result}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "webapp" {
  name                = "webapp-${random_integer.ri.result}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  app_service_plan_id = azurerm_app_service_plan.appserviceplan.id
depends_on = ["azurerm_app_service_plan.appserviceplan"]
}

resource "azurerm_app_service_virtual_network_swift_connection" "connection" {
  app_service_id = azurerm_app_service.webapp.id
  subnet_id      = azurerm_subnet.sub2.id
}

resource "azurerm_monitor_autoscale_setting" "autoscale" {
  name                = "autoscale-${random_integer.ri.result}"
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.location}"
  target_resource_id  = azurerm_app_service_plan.appserviceplan.id
  profile {
    name = "default"
    capacity {
      default = 1
      minimum = 1
      maximum = 10
    }
    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_app_service_plan.appserviceplan.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 90
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
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_app_service_plan.appserviceplan.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 10
      }
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }  
depends_on = ["azurerm_app_service.webapp"]
}

resource "azurerm_public_ip" "lb" {
  name                         = "kforceIPLB"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group_name}"
  public_ip_address_allocation = "static"
}


# Create Azure Load Balancer

resource "azurerm_lb" "lb" {
  name                = "${var.lb}"
  location 	      = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  frontend_ip_configuration {
    name                 = "LBFrontEnd"
    public_ip_address_id = "${azurerm_public_ip.lb.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "bepool" {
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "BackEndAddressPool"
  depends_on = ["azurerm_lb.lb"]
}

resource "azurerm_network_interface_backend_address_pool_association" "lbtarget1" {
  network_interface_id    = "${azurerm_network_interface.myterraformnic.0.id}"
  ip_configuration_name= "${azurerm_network_interface.myterraformnic.0.ip_configuration[0].name}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.bepool.id
  depends_on = ["azurerm_lb_backend_address_pool.bepool"]
}

resource "azurerm_network_interface_backend_address_pool_association" "lbtarget2" {
  network_interface_id    = "${azurerm_network_interface.myterraformnic.1.id}"
  ip_configuration_name= "${azurerm_network_interface.myterraformnic.1.ip_configuration[0].name}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.bepool.id		
  depends_on = ["azurerm_lb_backend_address_pool.bepool"]
}

resource "azurerm_lb_probe" "probe1" {
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id                = azurerm_lb.lb.id
  name                = "PROBE-443"
  port                = 443
  depends_on = ["azurerm_lb.lb"]
}

resource "azurerm_lb_rule" "rule1" {
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "LBRULE-443"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "LBFrontEnd"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.bepool.id
  probe_id                       = azurerm_lb_probe.probe1.id
  idle_timeout_in_minutes        = "4"
  load_distribution              = "SourceIPProtocol"
  depends_on = ["azurerm_lb_backend_address_pool.bepool"]
}


