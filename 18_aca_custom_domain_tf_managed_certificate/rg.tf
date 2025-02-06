resource "azurerm_resource_group" "rg" {
  name     = "rg-aca-custom-domain-managed-cert-${var.prefix}"
  location = "swedencentral"
}