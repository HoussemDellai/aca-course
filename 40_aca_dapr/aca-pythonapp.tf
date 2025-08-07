resource "azurerm_container_app" "aca_pythonapp" {
  name                         = "pythonapp"
  container_app_environment_id = azurerm_container_app_environment.aca_environment.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  #   identity {
  #     type         = "UserAssigned"
  #     identity_ids = [azurerm_user_assigned_identity.identity_aca_nodeapp.id]
  #   }
  dapr {
    app_id = "pythonapp"
    # app_port     = 3500
    # app_protocol = "http" # "grpc"
  }

  template {
    min_replicas = 1
    max_replicas = 1

    container {
      name   = "pythonapp"
      image  = "dapriosamples/hello-k8s-python:latest"
      cpu    = 0.25
      memory = "0.5Gi"

      #   env {
      #     name  = "APP_PORT"
      #     value = 3000
      #   }
    }
  }
}

# az containerapp create \
#   --name pythonapp \
#   --resource-group $RESOURCE_GROUP \
#   --environment $CONTAINERAPPS_ENVIRONMENT \
#   --image dapriosamples/hello-k8s-python:latest \
#   --min-replicas 1 \
#   --max-replicas 1 \
#   --enable-dapr \
#   --dapr-app-id pythonapp
