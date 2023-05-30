terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.58.0"
    }
  }
}

provider "azurerm" {
  features {}
  # Configuration options
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-aca-storage"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "la" {
  name                = "log-analytics-aca"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "aca_environment" {
  name                       = "aca-environment"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.la.id
}

resource "azurerm_storage_account" "storage" {
  name                     = "acaazurestorage013579"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "file_share" {
  name                 = "aca-file-share"
  storage_account_name = azurerm_storage_account.storage.name
  quota                = 5
}

resource "azurerm_container_app_environment_storage" "aca_env_storage" {
  name                         = "containerapp-storage"
  container_app_environment_id = azurerm_container_app_environment.aca_environment.id
  account_name                 = azurerm_storage_account.storage.name
  share_name                   = azurerm_storage_share.file_share.name
  access_key                   = azurerm_storage_account.storage.primary_access_key
  access_mode                  = "ReadWrite" # "ReadOnly"
}

resource "azurerm_container_app" "aca_app" {
  name                         = "aca-demo-app"
  container_app_environment_id = azurerm_container_app_environment.aca_environment.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "containerapp"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.25
      memory = "0.5Gi"

      volume_mounts {
        name      = "containerapp-storage"
        path = "/mnt/app-azure-file"
      }
    }

    volume {
      name = "containerapp-storage"
      storage_name = azurerm_container_app_environment_storage.aca_env_storage.name
      storage_type = "AzureFile" # "EmptyDir"
    }
  }
}
