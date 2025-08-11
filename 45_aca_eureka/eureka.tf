resource "azapi_resource" "aca_app_eureka" {
  type      = "Microsoft.App/managedEnvironments/javaComponents@2025-02-02-preview"
  parent_id = azurerm_container_app_environment.aca_environment.id
  name      = "eureka"

  body = {
    properties = {
      componentType  = "SpringCloudEureka"
      configurations = null
      scale = {
        maxReplicas = 1
        minReplicas = 1
      }
      serviceBinds = null
    }
  }

  depends_on = [azapi_resource.eureka]
}

# resource "azapi_update_resource" "aca_app_eureka" {
#   type        = "Microsoft.App/managedEnvironments/javaComponents@2025-02-02-preview"
#   resource_id = azurerm_container_app.aca_app_eureka_client.id

#   body = {
#     properties = {
#       template = {
#         serviceBinds = [
#           {
#             clientType = "none"
#             name       = "configserver"
#             serviceId  = "${azurerm_container_app_environment.aca_environment.id}/javaComponents/configserver"
#           },
#           {
#             clientType = "none"
#             name       = "eureka"
#             serviceId  = "${azurerm_container_app_environment.aca_environment.id}/javaComponents/eureka"
#           },
#           {
#             clientType = "none"
#             name       = "admin"
#             serviceId  = "${azurerm_container_app_environment.aca_environment.id}/javaComponents/admin"
#           }
#         ]
#       }
#     }
#   }

#   depends_on = [azapi_resource.eureka]
# }

resource "azapi_resource" "eureka" {
  type      = "Microsoft.App/managedEnvironments/javaComponents@2025-02-02-preview"
  name      = "eureka"
  parent_id = azurerm_container_app_environment.aca_environment.id

  body = {
    properties = {
      componentType = "SpringCloudEureka"
      ingress       = {}
      #   serviceBinds = null
      scale = {
        maxReplicas = 1
        minReplicas = 1
      }
      configurations = [
        {
          propertyName = "eureka.server.renewal-percent-threshold"
          value        = "0.85"
        },
        {
          propertyName = "eureka.server.eviction-interval-timer-in-ms"
          value        = "10000"
        }
      ]
    }
  }
}


# resource "azapi_resource" "eureka" {
#   type                      = "Microsoft.App/managedEnvironments/javaComponents@2025-02-02-preview"
#   parent_id                 = azurerm_container_app_environment.aca_environment.id
#   name                      = "eureka"
#   ignore_casing             = false
#   ignore_missing_property   = true
#   schema_validation_enabled = true

#   body = {
#     properties = {
#       componentType  = "SpringCloudEureka"
#       configurations = []
#       ingress        = {}
#       scale = {
#         maxReplicas = 1
#         minReplicas = 1
#       }
#     }
#   }

# }
