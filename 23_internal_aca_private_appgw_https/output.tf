# output "appgw_ip" {
#   value = azurerm_public_ip.pip-appgateway.ip_address
# }

output "app_fqdn" {
  value = azurerm_container_app.app.ingress.0.fqdn
}

output "custom_domain_name" {
  value = var.custom_domain_name
}

output "aca_inspector_gadget_fqdn" {
  value = azurerm_container_app.app.ingress.0.fqdn
}

output "vm_private_ip" {
  value = azurerm_network_interface.nic-vm-windows.private_ip_address
}

output "appgw_private_ip" {
  value = azurerm_application_gateway.appgateway.frontend_ip_configuration.0.private_ip_address
}