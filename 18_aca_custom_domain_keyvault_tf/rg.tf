resource "azurerm_resource_group" "rg" {
  name     = "rg-aca-custom-domain-kv-cert-${var.prefix}"
  location = "swedencentral"
}