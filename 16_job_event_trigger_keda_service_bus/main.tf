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
  name     = "rg-containerapp-keda"
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
  name                          = "acracakeda123579" # change this to a unique name
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

resource "azurerm_servicebus_namespace" "service-bus" {
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
  namespace_id        = azurerm_servicebus_namespace.service-bus.id
  enable_partitioning = false
  lock_duration       = "PT5M" # amount of time that the message is locked for other receivers, 1 min, max 5 min
  max_delivery_count  = 1
}

# Give the managed identity the RBAC role to receive messages from the queue
resource "azurerm_role_assignment" "role-receiver-queue-identity" {
  scope                = azurerm_servicebus_queue.queue-messages.id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = azurerm_user_assigned_identity.identity_aca.principal_id
}

# Give the managed identity the RBAC role to send messages to the queue
resource "azurerm_role_assignment" "role-sender-queue-identity" {
  scope                = azurerm_servicebus_queue.queue-messages.id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = azurerm_user_assigned_identity.identity_aca.principal_id
}

# Give the current user the RBAC role to receive messages from the queue
resource "azurerm_role_assignment" "role-receiver-queue-me" {
  scope                = azurerm_servicebus_queue.queue-messages.id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Give the current user the RBAC role to send messages to the queue
resource "azurerm_role_assignment" "role-sender-queue-me" {
  scope                = azurerm_servicebus_queue.queue-messages.id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = data.azurerm_client_config.current.object_id
}

data "azurerm_client_config" "current" {}

resource "terraform_data" "build_container_image" {
  count            = 1
  triggers_replace = [var.image_tag] # triggers build image when tag changes

  lifecycle {
    replace_triggered_by = [azurerm_container_registry.acr]
  }

  provisioner "local-exec" {
    when    = create
    command = <<-EOT
        az acr build -r ${azurerm_container_registry.acr.name} -f ./app/Dockerfile ./app/ -t job-python:${var.image_tag} --no-format
      EOT
  }
}

resource "terraform_data" "deploy_job" {
  count            = 1
  triggers_replace = [var.image_tag] # triggers build image when tag changes

  lifecycle {
    replace_triggered_by = [terraform_data.build_container_image]
  }

  provisioner "local-exec" {

    command = <<-EOT
        az containerapp job create \
          --name job-python \
          --resource-group ${azurerm_resource_group.rg.name} \
          --environment ${azurerm_container_app_environment.aca_environment.name} \
          --trigger-type "Event" \
          --replica-timeout 86400 \
          --replica-retry-limit 1 \
          --replica-completion-count 1 \
          --parallelism 1 \
          --image ${azurerm_container_registry.acr.name}.azurecr.io/job-python:${var.image_tag} \
          --registry-identity ${azurerm_user_assigned_identity.identity_aca.id} \
          --registry-server ${azurerm_container_registry.acr.name}.azurecr.io \
          --cpu 0.25 \
          --memory 0.5 \
          --min-executions 0 \
          --max-executions 1 \
          --secrets service-bus-connection-string="${azurerm_servicebus_namespace.service-bus.default_primary_connection_string}" \
          --scale-rule-name azure-servicebus-queue-rule \
          --scale-rule-type azure-servicebus \
          --scale-rule-auth "connection=service-bus-connection-string" \
          --scale-rule-metadata "queueName=${azurerm_servicebus_queue.queue-messages.name}" \
                                "namespace=${azurerm_servicebus_namespace.service-bus.name}" \
                                "messageCount=1" \
          --env-vars \
              SERVICEBUS_FQDN="${azurerm_servicebus_namespace.service-bus.name}.servicebus.windows.net" \
              MANAGED_IDENTITY_CLIENT_ID=${azurerm_user_assigned_identity.identity_aca.client_id} \
              SERVICEBUS_QUEUE_NAME=${azurerm_servicebus_queue.queue-messages.name}
      EOT
    when    = create
  }

  depends_on = [terraform_data.build_container_image]
}

variable "image_tag" {
  default = "1.0.7"
}
