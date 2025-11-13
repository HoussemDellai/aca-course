# resource "azurerm_container_app" "aca_app_inspectorgadget_consumption" {
#   count = 1

#   name                         = "aca-consumption-${count.index}"
#   container_app_environment_id = azurerm_container_app_environment.env.id
#   resource_group_name          = azurerm_resource_group.rg.name
#   revision_mode                = "Single"
#   workload_profile_name        = "Consumption"

#   template {
#     container {
#       name   = "aca-app"
#       image  = "ghcr.io/jelledruyts/inspectorgadget:latest"
#       cpu    = 0.25
#       memory = "0.5Gi"
#     }
#   }

#   ingress {
#     allow_insecure_connections = false
#     external_enabled           = true
#     target_port                = 80
#     transport                  = "auto"

#     traffic_weight {
#       latest_revision = true
#       percentage      = 100
#     }
#   }
# }

# # output "aca_app_inspectorgadget_consumption_fqdn" {
# #   value = azurerm_container_app.aca_app_inspectorgadget_consumption.latest_revision_fqdn
# # }
