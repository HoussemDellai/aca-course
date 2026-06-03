resource "azurerm_resource_group" "rg" {
  name     = "rg-containerapp-keda-service-bus-${var.prefix}"
  location = "swedencentral"
}