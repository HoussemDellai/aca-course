resource "azurerm_resource_group" "rg" {
  name     = "rg-aca-serverless-gpu-nvidia-llm-itn-${var.prefix}"
  location = "italynorth" # "swedencentral"

  tags = { 
    SecurityControl = "Ignore"
  }
}