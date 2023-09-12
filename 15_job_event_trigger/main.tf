terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.72.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-aca-job-event-trigger"
  location = "westeurope"
}

resource "azurerm_container_app_environment" "aca_environment" {
  name                       = "aca-environment"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
}

resource "azurerm_servicebus_namespace" "service-bus" {
  name                          = "service-bus-namespace-13579"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  sku                           = "Standard"
  capacity                      = 0
  zone_redundant                = false
  public_network_access_enabled = true
}

resource "azurerm_servicebus_queue" "queue-messages" {
  name                = "queue-messages"
  namespace_id        = azurerm_servicebus_namespace.service-bus.id
  enable_partitioning = false
  lock_duration       = "PT5M" # amount of time that the message is locked for other receivers, 1 min, max 5 min
  max_delivery_count  = 1
}

resource "terraform_data" "deploy_job" {
  triggers_replace = {
    when = timestamp()
  }
  provisioner "local-exec" {

    when        = create
    interpreter = ["PowerShell", "-Command"]
    command     = <<-EOT
      az containerapp job create `
        --name aca-job-keda `
        --resource-group ${azurerm_resource_group.rg.name} `
        --environment ${azurerm_container_app_environment.aca_environment.name} `
        --replica-timeout 600 `
        --replica-retry-limit 1 `
        --replica-completion-count 1 `
        --parallelism 1 `
        --image "mcr.microsoft.com/k8se/quickstart-jobs:latest" `
        --cpu "0.25" `
        --memory "0.5Gi" `
        --min-executions 0 `
        --max-executions 1 `
        --trigger-type "Event" `
        --secrets service-bus-connection-string="${azurerm_servicebus_namespace.service-bus.default_primary_connection_string}" `
        --scale-rule-name azure-servicebus-queue-rule `
        --scale-rule-type azure-servicebus `
        --scale-rule-auth "connection=service-bus-connection-string" `
        --scale-rule-metadata "namespace=${azurerm_servicebus_namespace.service-bus.name}" `
                              "queueName=${azurerm_servicebus_queue.queue-messages.name}" `
                              "messageCount=1"
      EOT
  }
}