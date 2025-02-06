resource "azurerm_private_endpoint" "pe" {
  name                = "pe-aca-environment"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.snet-pe.id

  private_service_connection {
    name                           = "connection-pe"
    private_connection_resource_id = azurerm_container_app_environment.env.id
    is_manual_connection           = false
    subresource_names              = ["managedEnvironments"]
  }

  private_dns_zone_group {
    name                 = "group-aca-environment"
    private_dns_zone_ids = [azurerm_private_dns_zone.private-dns-zone-aca-environment.id]
  }

  depends_on = [ azapi_update_resource.disable-aca-env-public-access ]
}