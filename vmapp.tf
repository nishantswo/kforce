# Create virtual machine
resource "azurerm_virtual_machine" "myterraformvmapp" {
    count               = var.node_count
    name                  = "${var.vm_nameapp}${count.index+1}"
    location              = "${var.location}"
    resource_group_name   = "${azurerm_resource_group.rg.name}"
    network_interface_ids = [azurerm_network_interface.myterraformnicapp[count.index].id]
    vm_size               = "${var.vm_size}"
    availability_set_id   = "${azurerm_availability_set.avsetapp.id}"
    delete_os_disk_on_termination    = true
    delete_data_disks_on_termination = true


    storage_os_disk {
        name              = "${var.vm_nameapp}${count.index+1}_OS_disk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        os_type 	  = "Windows"
        managed_disk_type = "Standard_LRS"
    }

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }


    os_profile {
        computer_name  = "${var.vm_nameapp}${count.index+1}"
        admin_username = "azureuser"
		admin_password = "${data.azurerm_key_vault_secret.mySecret.value}"
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
        storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
    }

}
