terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.102.0"
    }
    # acme = {
    #   source  = "vancluever/acme"
    #   version = ">= 2.18.0"
    # }
    azapi = {
      source  = "azure/azapi"
      version = ">= 1.13.1"
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
