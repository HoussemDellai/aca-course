resource "azurerm_network_interface" "nic-vm-windows" {
  name                = "nic-vm-windows"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet-jumpbox.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = null
  }
}

resource "azurerm_windows_virtual_machine" "jumpbox" {
  name                  = "vm-windows-w11"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = "Standard_D4ads_v6"
  admin_username        = "azureuser"
  admin_password        = "@Aa123456789"
  network_interface_ids = [azurerm_network_interface.nic-vm-windows.id]
  priority              = "Spot"
  eviction_policy       = "Delete"
  disk_controller_type  = "NVMe" # "SCSI" # "IDE" # "SCSI" is the default value. "NVMe" is only supported for Ephemeral OS Disk.

  os_disk {
    name                 = "os-disk-win11"
    caching              = "ReadOnly"        # "ReadWrite" # None, ReadOnly and ReadWrite.
    storage_account_type = "StandardSSD_LRS" # "Standard_LRS"
    disk_size_gb         = 128

    diff_disk_settings {
      option    = "Local"    # Specifies the Ephemeral Disk Settings for the OS Disk. At this time the only possible value is Local.
      placement = "NvmeDisk" # "ResourceDisk" # "CacheDisk" # Specifies the Ephemeral Disk Placement for the OS Disk. NvmeDisk can only be used for v6 VMs
    }
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-25h2-pro"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = null
  }

  lifecycle {
    ignore_changes = [identity]
  }
}
