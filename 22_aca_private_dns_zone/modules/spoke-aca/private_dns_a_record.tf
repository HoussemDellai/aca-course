locals {
  aca_env_unique_id = split(".", azurerm_container_app_environment.env.default_domain)[0]
}

resource "azurerm_private_dns_a_record" "a-record-nginx" {
  name                = "${azurerm_container_app.nginx.name}.${local.aca_env_unique_id}" # "nginx.wittyriver-31a5fd3e"
  zone_name           = var.private_dns_zone.name
  resource_group_name = var.private_dns_zone.resource_group_name
  ttl                 = 300
  records             = [azurerm_container_app_environment.env.static_ip_address]
}