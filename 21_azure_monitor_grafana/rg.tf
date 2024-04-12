resource "azurerm_resource_group" "rg" {
  name     = "rg-containerapps-grafana-${var.prefix}"
  location = var.location
}