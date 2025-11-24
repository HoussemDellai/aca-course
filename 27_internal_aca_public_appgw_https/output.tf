output "custom_domain_name" {
  value = var.custom_domain_name
}

output "aca_nginx_fqdn" {
  value = azurerm_container_app.aca-nginx.ingress.0.fqdn
}

output "aca_inspector_gadget_fqdn" {
  value = azurerm_container_app.aca-inspector-gadget.ingress.0.fqdn
}

output "vm_private_ip" {
  value = azurerm_network_interface.nic-vm-windows.private_ip_address
}

output "appgw_public_ip" {
  value = azurerm_public_ip.pip-appgateway.ip_address
}