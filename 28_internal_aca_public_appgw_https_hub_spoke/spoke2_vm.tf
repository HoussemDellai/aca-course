# module "vm-spoke2" {
#   source              = "../modules/vm_linux"
#   vm_name             = "vm-spoke2"
#   resource_group_name = azurerm_resource_group.rg-spoke2.name
#   location            = azurerm_resource_group.rg-spoke2.location
#   subnet_id           = azurerm_subnet.subnet-spoke2-workload.id
#   admin_username      = var.vm_admin_username
#   admin_password      = var.vm_admin_password
#   install_webapp      = true
# }
