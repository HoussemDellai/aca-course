resource "azurerm_container_app_job" "aca_job" {
  name                         = "aca-job-python"
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  container_app_environment_id = azurerm_container_app_environment.aca_environment.id
  workload_profile_name        = "Consumption"
  replica_timeout_in_seconds   = 300
  replica_retry_limit          = 10

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.identity_aca_servicebus.id,
      azurerm_user_assigned_identity.identity_aca_acr.id
    ]
  }

  event_trigger_config {
    parallelism              = 3
    replica_completion_count = 1
    scale {
      min_executions              = 0
      max_executions              = 1
      polling_interval_in_seconds = 30

      rules {
        name             = "azure-servicebus-queue-rule"
        custom_rule_type = "azure-servicebus"
        metadata = {
          queueName    = azurerm_servicebus_queue.queue_messages.name
          namespace    = azurerm_servicebus_namespace.service_bus.name
          messageCount = "1"
        }

        identity_id = azurerm_user_assigned_identity.identity_aca_servicebus.id

        # authentication {
        #   secret_name       = "service-bus-connection-string"
        #   trigger_parameter = "connection"
        # }
      }
    }
  }

  registry {
    server   = "${azurerm_container_registry.acr.name}.azurecr.io"
    identity = azurerm_user_assigned_identity.identity_aca_acr.id
  }

  # secret {
  #   name  = "service-bus-connection-string"
  #   value = azurerm_servicebus_namespace.service_bus.default_primary_connection_string
  #   # identity = 
  #   # key_vault_secret_id = 
  # }

  template {
    container {
      image  = "${azurerm_container_registry.acr.name}.azurecr.io/job-python:1.0.0"
      name   = "job-python"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "SERVICEBUS_FQDN"
        value = "${azurerm_servicebus_namespace.service_bus.name}.servicebus.windows.net"
      }
      env {
        name  = "MANAGED_IDENTITY_CLIENT_ID"
        value = azurerm_user_assigned_identity.identity_aca_servicebus.client_id
      }
      env {
        name  = "SERVICEBUS_QUEUE_NAME"
        value = azurerm_servicebus_queue.queue_messages.name
      }
    }
  }
}

output "aca_job_outbound_ip_addresses" {
  value = azurerm_container_app_job.aca_job.outbound_ip_addresses
}
