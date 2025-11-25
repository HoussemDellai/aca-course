output "appgw_public_ip" {
  value = azurerm_public_ip.pip-appgateway.ip_address
}

output "custom_domain_name" {
  value = azurerm_dns_zone.dns-zone-apps.name
}