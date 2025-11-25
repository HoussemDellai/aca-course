data "azurerm_monitor_diagnostic_categories" "categories-appgateway" {
  resource_id = azurerm_application_gateway.appgateway.id
}

resource "azurerm_monitor_diagnostic_setting" "diagnostics_appgateway" {
  name                           = "diagnostic-settings-appgateway"
  target_resource_id             = azurerm_application_gateway.appgateway.id
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.workspace.id
  log_analytics_destination_type = "Dedicated" # "AzureDiagnostics"

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.categories-appgateway.log_category_types

    content {
      category = enabled_log.key
    }
  }

  dynamic "enabled_metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.categories-firewall.metrics

    content {
      category = enabled_metric.key
    }
  }

  lifecycle {
    ignore_changes = [
      log_analytics_destination_type
    ]
  }
}
