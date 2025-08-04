# output "appgw_ip" {
#   value = azurerm_public_ip.pip-appgateway.ip_address
# }

# output "app_fqdn" {
#   value = azurerm_container_app.app.ingress.0.fqdn
# }

output "custom_domain_name" {
  value = var.custom_domain_name
}

output "apps_url" {
  value = { for k, v in azurerm_private_dns_a_record.a-record-app : k => "https://${v.fqdn}" }
}