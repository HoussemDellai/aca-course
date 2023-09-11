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

resource "azurerm_container_registry" "acr" {
  name                          = "acracajob123579" # change this to a unique name
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  sku                           = "Basic"
  admin_enabled                 = false
  public_network_access_enabled = true
  zone_redundancy_enabled       = false
  anonymous_pull_enabled        = false
  data_endpoint_enabled         = false
  network_rule_bypass_option    = "AzureServices"
}

resource "terraform_data" "build_container_image" {
  triggers_replace = [var.image_tag] # triggers build image when tag changes

  lifecycle {
    replace_triggered_by = [azurerm_container_registry.acr]
  }

  provisioner "local-exec" {
    when    = create
    command = <<-EOT
        az acr build -r ${azurerm_container_registry.acr.name} -f .\app\Dockerfile .\app\ -t job-python:${var.image_tag}
      EOT
  }
}

resource "azurerm_user_assigned_identity" "identity_aca" {
  name                = "identity-aca"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_role_assignment" "role_acr_aca" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.identity_aca.principal_id
}

resource "azurerm_servicebus_namespace" "service_bus" {
  name                          = "servicebus-ns-job"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  sku                           = "Standard"
  capacity                      = 0
  zone_redundant                = false
  public_network_access_enabled = true
}

resource "azurerm_servicebus_queue" "queue-messages" {
  name                = "queue-messages"
  namespace_id        = azurerm_servicebus_namespace.service_bus.id
  enable_partitioning = false
  lock_duration       = "PT5M" # amount of time that the message is locked for other receivers, 1 min, max 5 min
  max_delivery_count  = 1
  # max_message_size_in_kilobytes
  # max_size_in_megabytes 
}

resource "azurerm_servicebus_queue_authorization_rule" "auth-rule" {
  name     = "listen-and-send"
  queue_id = azurerm_servicebus_queue.queue-messages.id

  listen = true
  send   = true
  manage = false
}

# Give current user the RBAC role to send messages to the queue
resource "azurerm_role_assignment" "role-sender-queue-me" {
  scope                = azurerm_servicebus_queue.queue-messages.id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Give current user the RBAC role to receive messages from the queue
resource "azurerm_role_assignment" "role-receiver-queue-me" {
  scope                = azurerm_servicebus_queue.queue-messages.id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Give the managed identity the RBAC role to send messages to the queue
resource "azurerm_role_assignment" "role-receiver-queue-identity" {
  scope                = azurerm_servicebus_queue.queue-messages.id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = azurerm_user_assigned_identity.identity_aca.principal_id
}

# Give the managed identity the RBAC role to receive messages from the queue
resource "azurerm_role_assignment" "role-sender-queue-identity" {
  scope                = azurerm_servicebus_queue.queue-messages.id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = azurerm_user_assigned_identity.identity_aca.principal_id
}

data "azurerm_client_config" "current" {}

resource "terraform_data" "deploy_job" {
  triggers_replace = [var.image_tag] # triggers build image when tag changes

  lifecycle {
    replace_triggered_by = [terraform_data.build_container_image]
  }

  provisioner "local-exec" {

    command = <<-EOT
        az containerapp job create `
          --name job-python `
          --resource-group ${azurerm_resource_group.rg.name} `
          --environment ${azurerm_container_app_environment.aca_environment.name} `
          --trigger-type "Event" `
          --replica-timeout 86400 `
          --replica-retry-limit 1 `
          --replica-completion-count 1 `
          --parallelism 1 `
          --image ${azurerm_container_registry.acr.name}.azurecr.io/job-python:${var.image_tag} `
          --cpu 1 `
          --memory 2 `
          --min-executions 0 `
          --max-executions 1 `
          --secrets service-bus-connection-string=${azurerm_servicebus_queue_authorization_rule.auth-rule.primary_connection_string} `
          --env-vars `
              AZURE_CLIENT_ID=${azurerm_user_assigned_identity.identity_aca.client_id} `
              FULLY_QUALIFIED_NAMESPACE=${azurerm_servicebus_namespace.service_bus.endpoint} `
              MANAGED_IDENTITY_CLIENT_ID=${azurerm_user_assigned_identity.identity_aca.client_id} `
              INPUT_QUEUE_NAME=${azurerm_servicebus_queue.queue-messages.name} `
          --scale-rule-name azure-servicebus-queue-rule `
          --scale-rule-type azure-servicebus `
          --scale-rule-metadata "queueName=${azurerm_servicebus_queue.queue-messages.name}" `
                                "namespace=${azurerm_servicebus_namespace.service_bus.name}" `
                                "messageCount=1" `
          --scale-rule-auth "connection=service-bus-connection-string" `
          --registry-identity ${azurerm_user_assigned_identity.identity_aca.id} `
          --registry-server ${azurerm_container_registry.acr.name}.azurecr.io
      EOT
    when    = create
  }

  depends_on = [terraform_data.build_container_image]
}

output "service_bus" {
  sensitive = true
  value = {
    endpoint                  = azurerm_servicebus_namespace.service_bus.endpoint
    id                        = azurerm_servicebus_namespace.service_bus.id
    primary_connection_string = azurerm_servicebus_namespace.service_bus.default_primary_connection_string
  }
}

output "managed_identity" {
  sensitive = true
  value = {
    client_id    = azurerm_user_assigned_identity.identity_aca.client_id
    principal_id = azurerm_user_assigned_identity.identity_aca.principal_id
    id           = azurerm_user_assigned_identity.identity_aca.id
  }
}

variable "image_tag" {
  default = "1.0.1"
}
