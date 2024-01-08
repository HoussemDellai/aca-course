output "appgw_ip" {
  value = azurerm_public_ip.pip-appgateway.ip_address
}

output "app_url" {
  value = azurerm_container_app.app.latest_revision_fqdn
}