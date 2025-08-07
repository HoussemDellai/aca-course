resource "azurerm_container_app" "aca_nodeapp" {
  name                         = "nodeapp"
  container_app_environment_id = azurerm_container_app_environment.aca_environment.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.identity_aca_nodeapp.id]
  }

  dapr {
    app_id       = "nodeapp"
    app_port     = 3000
    app_protocol = "http" # "grpc"
  }

  template {
    min_replicas = 1
    max_replicas = 1
    
    container {
      name   = "nodeapp"
      image  = "dapriosamples/hello-k8s-node:latest"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "APP_PORT"
        value = 3000
      }
    }
  }

  ingress {
    target_port      = 3000
    external_enabled = false

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}

# az containerapp create \
#   --name nodeapp \
#   --resource-group $RESOURCE_GROUP \
#   --user-assigned $IDENTITY_ID \
#   --environment $CONTAINERAPPS_ENVIRONMENT \
#   --image dapriosamples/hello-k8s-node:latest \
#   --min-replicas 1 \
#   --max-replicas 1 \
#   --enable-dapr \
#   --dapr-app-id nodeapp \
#   --dapr-app-port 3000 \
#   --env-vars 'APP_PORT=3000'
