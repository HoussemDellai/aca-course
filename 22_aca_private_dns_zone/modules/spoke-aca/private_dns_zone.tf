# resource "azurerm_private_dns_zone" "private-dns-zone" {
#   name                = azurerm_container_app_environment.env.default_domain
#   resource_group_name = azurerm_resource_group.rg.name
# }

# resource "azurerm_private_dns_a_record" "a-record" {
#   name                = "@"
#   zone_name           = azurerm_private_dns_zone.private-dns-zone.name
#   resource_group_name = azurerm_resource_group.rg.name
#   ttl                 = 300
#   records             = [azurerm_container_app_environment.env.static_ip_address]
# }

# resource "azurerm_private_dns_a_record" "a-record-wild-card" {
#   name                = "*"
#   zone_name           = azurerm_private_dns_zone.private-dns-zone.name
#   resource_group_name = azurerm_resource_group.rg.name
#   ttl                 = 300
#   records             = [azurerm_container_app_environment.env.static_ip_address]
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "link-vnet-spoke" {
#   name                  = "link-vnet-spoke"
#   resource_group_name   = azurerm_resource_group.rg.name
#   private_dns_zone_name = azurerm_private_dns_zone.private-dns-zone.name
#   virtual_network_id    = azurerm_virtual_network.vnet-spoke.id
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "link-vnet-hub" {
#   name                  = "link-vnet-hub"
#   resource_group_name   = azurerm_resource_group.rg.name
#   private_dns_zone_name = azurerm_private_dns_zone.private-dns-zone.name
#   virtual_network_id    = var.vnet_hub.id
# }
