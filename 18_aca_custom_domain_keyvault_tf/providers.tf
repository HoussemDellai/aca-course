terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.17.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = ">= 2.2.0"
    }
  }
}

provider "azurerm" {
  features {
  }
}

# provider "acme" {
#   server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
# }

