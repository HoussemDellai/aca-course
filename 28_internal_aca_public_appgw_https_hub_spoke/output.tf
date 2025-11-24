output "aca_inspector_gadget_fqdn" {
  value = azurerm_container_app.aca-inspector-gadget.ingress.0.fqdn
}

output "aca_nginx_fqdn" {
  value = azurerm_container_app.aca-nginx.ingress.0.fqdn
}

output "appgw_public_ip" {
  value = azurerm_public_ip.pip-appgateway.ip_address
}

output "custom_domain_name" {
  value = azurerm_dns_zone.dns-zone-apps.name
}