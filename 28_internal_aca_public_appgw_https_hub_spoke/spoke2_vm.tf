resource "azurerm_network_interface" "nic-vm-spoke2" {
  name                  = "nic-vm-spoke2"
  resource_group_name   = azurerm_resource_group.rg-spoke2.name
  location              = azurerm_resource_group.rg-spoke2.location
  ip_forwarding_enabled = false

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet-spoke2-vm.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = null
  }
}

resource "azurerm_linux_virtual_machine" "vm-spoke2" {
  name                            = "vm-linux-spoke2"
  resource_group_name             = azurerm_resource_group.rg-spoke2.name
  location                        = azurerm_resource_group.rg-spoke2.location
  size                            = "Standard_D2ads_v6"
  disable_password_authentication = false
  admin_username                  = "azureuser"
  admin_password                  = "@Aa123456789"
  network_interface_ids           = [azurerm_network_interface.nic-vm-spoke2.id]
  priority                        = "Spot"
  eviction_policy                 = "Delete"
  disk_controller_type            = "NVMe" # "SCSI" # "IDE" # "SCSI" is the default value. "NVMe" is only supported for Ephemeral OS Disk.

  # custom_data = filebase64("./install-traceroute.sh")

  os_disk {
    name                 = "os-disk-vm-spoke2"
    caching              = "ReadOnly"        # "ReadWrite" # None, ReadOnly and ReadWrite.
    storage_account_type = "StandardSSD_LRS" # "Standard_LRS"
    disk_size_gb         = 64

    diff_disk_settings {
      option    = "Local"    # Specifies the Ephemeral Disk Settings for the OS Disk. At this time the only possible value is Local.
      placement = "NvmeDisk" # "ResourceDisk" # "CacheDisk" # Specifies the Ephemeral Disk Placement for the OS Disk. NvmeDisk can only be used for v6 VMs
    }
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts" # "0001-com-ubuntu-server-jammy"
    sku       = "server"           # "22_04-lts"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = null
  }
}

output "vm_spoke2_ip" {
  value = azurerm_linux_virtual_machine.vm-spoke2.private_ip_address
}