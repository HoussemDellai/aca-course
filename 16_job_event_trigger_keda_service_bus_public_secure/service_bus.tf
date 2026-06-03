resource "azurerm_servicebus_namespace" "service_bus" {
  name                          = "servicebus-ns-std-${var.prefix}" # change this to a unique name
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  sku                           = "Standard"
  capacity                      = 0
  local_auth_enabled            = true
  public_network_access_enabled = true

  network_rule_set {
    default_action                = "Deny"
    public_network_access_enabled = true
    trusted_services_allowed      = true
    ip_rules                      = ["9.160.9.0/24", azurerm_public_ip_prefix.pip_prefix_nat_gateway.ip_prefix] # [azurerm_container_app_job.aca_job.outbound_ip_addresses] # One or more IP Addresses, or CIDR Blocks which should be able to access the Service Bus Namespace.

    # network_rules {
    #   subnet_id                            = azurerm_subnet.snet_aca.id
    #   ignore_missing_vnet_service_endpoint = true
    # }
  }

  tags = {
    SecurityControl = "Ignore"
  }
}

resource "azurerm_servicebus_queue" "queue_messages" {
  name               = "queue-messages"
  namespace_id       = azurerm_servicebus_namespace.service_bus.id
  lock_duration      = "PT5M" # amount of time that the message is locked for other receivers, 1 min, max 5 min
  max_delivery_count = 1
}

# Give the current user the RBAC role to receive messages from the queue
resource "azurerm_role_assignment" "role_receiver_queue_me" {
  scope                = azurerm_servicebus_queue.queue_messages.id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Give the current user the RBAC role to send messages to the queue
resource "azurerm_role_assignment" "role_sender_queue_me" {
  scope                = azurerm_servicebus_queue.queue_messages.id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = data.azurerm_client_config.current.object_id
}

data "azurerm_client_config" "current" {}

output "service_bus_endpoint" {
  value = azurerm_servicebus_namespace.service_bus.endpoint
}
