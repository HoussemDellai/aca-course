resource "azurerm_resource_group" "rg" {
  name     = "rg-aca-deepseek-r1-${var.prefix}"
  location = "swedencentral"
}