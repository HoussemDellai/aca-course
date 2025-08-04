
resource "azurerm_servicebus_namespace" "service-bus" {
  name                          = "servicebus-ns-job"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  sku                           = "Standard"
  capacity                      = 0
  public_network_access_enabled = true
}

resource "azurerm_servicebus_queue" "queue-messages" {
  name               = "queue-messages"
  namespace_id       = azurerm_servicebus_namespace.service-bus.id
  lock_duration      = "PT5M" # amount of time that the message is locked for other receivers, 1 min, max 5 min
  max_delivery_count = 1
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
