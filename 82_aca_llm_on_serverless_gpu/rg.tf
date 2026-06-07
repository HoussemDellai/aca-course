resource "azurerm_resource_group" "rg" {
  name     = "rg-aca-llm-on-serverless-gpu-nvidia-${var.prefix}"
  location = "swedencentral"
}