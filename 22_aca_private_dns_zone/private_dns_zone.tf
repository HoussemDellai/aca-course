resource "azurerm_private_dns_zone" "private-dns-zone" {
  name                = "${var.location}.azurecontainerapps.io"
  resource_group_name = azurerm_resource_group.rg-hub.name
}

# resource "azurerm_private_dns_a_record" "a-record" {
#   name                = "wittyriver-31a5fd3e"
#   zone_name           = azurerm_private_dns_zone.private-dns-zone.name
#   resource_group_name = azurerm_resource_group.rg-hub.name
#   ttl                 = 300
#   records             = ["10.1.0.184"]
# }

# resource "azurerm_private_dns_a_record" "a-record-nginx" {
#   name                = "nginx.wittyriver-31a5fd3e"
#   zone_name           = azurerm_private_dns_zone.private-dns-zone.name
#   resource_group_name = azurerm_resource_group.rg-hub.name
#   ttl                 = 300
#   records             = ["10.1.0.184"]
# }

# resource "azurerm_private_dns_a_record" "a-record-2" {
#   name                = "wonderfulground-84f6fafd"
#   zone_name           = azurerm_private_dns_zone.private-dns-zone.name
#   resource_group_name = azurerm_resource_group.rg-hub.name
#   ttl                 = 300
#   records             = ["10.2.0.247"]
# }

# resource "azurerm_private_dns_a_record" "a-record-2-nginx" {
#   name                = "nginx.wonderfulground-84f6fafd"
#   zone_name           = azurerm_private_dns_zone.private-dns-zone.name
#   resource_group_name = azurerm_resource_group.rg-hub.name
#   ttl                 = 300
#   records             = ["10.2.0.247"]
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "link-vnet-spoke" {
#   name                  = "link-vnet-spoke"
#   resource_group_name   = azurerm_resource_group.rg-hub.name
#   private_dns_zone_name = azurerm_private_dns_zone.private-dns-zone.name
#   virtual_network_id    = azurerm_virtual_network.vnet-spoke.id
# }

resource "azurerm_private_dns_zone_virtual_network_link" "link-vnet-hub" {
  name                  = "link-vnet-hub"
  resource_group_name   = azurerm_resource_group.rg-hub.name
  private_dns_zone_name = azurerm_private_dns_zone.private-dns-zone.name
  virtual_network_id    = azurerm_virtual_network.vnet-hub.id
}
