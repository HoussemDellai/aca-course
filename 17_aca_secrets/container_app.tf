resource "azurerm_container_app_environment" "aca_environment" {
  name                = "aca-environment"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_container_app" "aca_app" {
  name                         = "aca-app-demo"
  container_app_environment_id = azurerm_container_app_environment.aca_environment.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "aca-app"
      image  = "ghcr.io/jelledruyts/inspectorgadget:latest"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "MY_ENV_VAR"
        value = "Hello Container Apps!"
      }
      env {
        name        = "MY_SECRET_01"
        secret_name = "my-secret-01"
      }
    }
  }

  secret {
    name  = "my-secret-01"
    value = "My Secret Connection String value"
    # expect secret_ref to be added to azurerm provider
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.identity_aca.id]
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 80
    transport                  = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  lifecycle {
    ignore_changes = [ secret ]
  }
}

output "app_url" {
  value = azurerm_container_app.aca_app.latest_revision_fqdn
}

resource "terraform_data" "add_secrets" {
  count            = 1
  triggers_replace = []

  lifecycle {
    replace_triggered_by = [azurerm_container_app.aca_app]
  }

  provisioner "local-exec" {

    # interpreter = [ "bash", "-c" ]
    interpreter = ["PowerShell", "-Command"]

    command = <<-EOT
    
        az containerapp secret set `
          --name ${azurerm_container_app.aca_app.name} `
          --resource-group ${azurerm_resource_group.rg.name} `
          --secrets my-secret-02=keyvaultref:${azurerm_key_vault_secret.secret_02.versionless_id},identityref:${azurerm_user_assigned_identity.identity_aca.id}

          az containerapp update `
          --name ${azurerm_container_app.aca_app.name} `
          --resource-group ${azurerm_resource_group.rg.name} `
          --set-env-vars "MY_SECRET_02=secretref:my-secret-02"
         
      EOT
    when    = create
  }

  depends_on = [azurerm_container_app.aca_app]
}
