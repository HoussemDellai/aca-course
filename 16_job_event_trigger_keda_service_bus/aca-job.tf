resource "azurerm_container_app_job" "aca-job" {
  name                         = "aca-job-python"
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  container_app_environment_id = azurerm_container_app_environment.aca_environment.id
  replica_timeout_in_seconds   = 300
  replica_retry_limit          = 10

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.identity_aca.id]
  }

  event_trigger_config {
    parallelism              = 1
    replica_completion_count = 1
    scale {
      min_executions              = 0
      max_executions              = 1
      polling_interval_in_seconds = 30

      rules {
        name             = "azure-servicebus-queue-rule"
        custom_rule_type = "azure-servicebus"
        metadata = {
          queueName    = azurerm_servicebus_queue.queue-messages.name
          namespace    = azurerm_servicebus_namespace.service-bus.name
          messageCount = "1"
        }
        authentication {
          secret_name       = "service-bus-connection-string"
          trigger_parameter = "connection"
        }
      }
    }
  }

  registry {
    server   = "${azurerm_container_registry.acr.name}.azurecr.io"
    identity = azurerm_user_assigned_identity.identity_aca.id
  }

  secret {
    name  = "service-bus-connection-string"
    value = azurerm_servicebus_namespace.service-bus.default_primary_connection_string
    # identity = 
    # key_vault_secret_id = 
  }

  template {
    container {
      image  = "${azurerm_container_registry.acr.name}.azurecr.io/job-python:${var.image_tag}"
      name   = "job-python"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "SERVICEBUS_FQDN"
        value = "${azurerm_servicebus_namespace.service-bus.name}.servicebus.windows.net"
      }
      env {
        name  = "MANAGED_IDENTITY_CLIENT_ID"
        value = azurerm_user_assigned_identity.identity_aca.client_id
      }
      env {
        name  = "SERVICEBUS_QUEUE_NAME"
        value = azurerm_servicebus_queue.queue-messages.name
      }
    }
  }
}

variable "image_tag" {
  default = "1.0.0"
}
