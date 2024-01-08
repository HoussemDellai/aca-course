resource "azurerm_resource_group" "rg" {
  name     = "rg-containerapps-internal-appgw"
  location = "westeurope"
}