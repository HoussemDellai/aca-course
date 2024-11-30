resource "azurerm_resource_group" "rg" {
  name     = "rg-aca-service-connector-${var.prefix}"
  location = "swedencentral"
}
