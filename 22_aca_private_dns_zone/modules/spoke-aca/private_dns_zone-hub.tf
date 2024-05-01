# Creates an "A" record into the Hub's central Private DNS Zone

# resource "azurerm_private_dns_a_record" "a-record-nginx" {
#   name                = "${azurerm_container_app.nginx.name}.${local.aca_env_unique_id}" # "nginx.wittyriver-31a5fd3e"
#   zone_name           = data.azurerm_private_dns_zone.private_dns_zone.name
#   resource_group_name = data.azurerm_private_dns_zone.private_dns_zone.resource_group_name
#   ttl                 = 300
#   records             = [azurerm_container_app_environment.env.static_ip_address]
# }

resource "azurerm_private_dns_a_record" "a-record-nginx" {
  name                = "*.${local.aca_env_unique_id}" # "nginx.wittyriver-31a5fd3e"
  zone_name           = var.private_dns_zone.name
  resource_group_name = var.private_dns_zone.resource_group_name
  ttl                 = 300
  records             = [azurerm_container_app_environment.env.static_ip_address]
}

locals {
  aca_env_unique_id = split(".", azurerm_container_app_environment.env.default_domain)[0]
}

resource "azurerm_private_dns_zone_virtual_network_link" "link-vnet-spoke" {
  name                  = "link-vnet-spoke-${var.prefix}"
  private_dns_zone_name = var.private_dns_zone.name
  resource_group_name   = var.private_dns_zone.resource_group_name
  virtual_network_id    = azurerm_virtual_network.vnet-spoke.id
}
