resource "azurerm_user_assigned_identity" "identity_aca_servicebus" {
  name                = "identity-aca-servicebus"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

# Give the managed identity the RBAC role to receive messages from the queue
resource "azurerm_role_assignment" "role_servicebus_aca" {
  scope                = azurerm_servicebus_namespace.service_bus.id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = azurerm_user_assigned_identity.identity_aca_servicebus.principal_id
}