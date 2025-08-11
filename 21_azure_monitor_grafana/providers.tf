terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 4.39.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
}