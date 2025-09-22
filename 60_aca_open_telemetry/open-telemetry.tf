resource "azapi_update_resource" "app_insights_open_telemetry_integration" {
  name      = azurerm_container_app_environment.aca_environment.name
  parent_id = azurerm_resource_group.rg.id
  type      = "Microsoft.App/managedEnvironments@2025-02-02-preview"

  body = {
    properties = {
      appInsightsConfiguration = {
        connectionString = azurerm_application_insights.app_insights.connection_string
      }
      appLogsConfiguration = {
        destination = "log-analytics"
        logAnalyticsConfiguration = {
          customerId = azurerm_log_analytics_workspace.la.workspace_id
          sharedKey  = azurerm_log_analytics_workspace.la.primary_shared_key
        }
      }
      openTelemetryConfiguration = {
        tracesConfiguration = {
          destinations = ["appInsights"]
        }
        logsConfiguration = {
          destinations = ["appInsights"]
        }
      }
    }
  }
}
