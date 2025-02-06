output "app_consumption_fqdn" {
  value = azurerm_container_app.deepseek-r1.ingress.0.fqdn
}

# output "app_fqdn" {
#   value = azurerm_container_app.app.ingress.0.fqdn
# }