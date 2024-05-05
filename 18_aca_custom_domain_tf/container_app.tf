resource "azurerm_container_app" "inspactor-gadget" {
  name                         = "inspactor-gadget"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "app"
      image  = "jelledruyts/inspectorgadget"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    allow_insecure_connections = true
    external_enabled           = true
    target_port                = 80

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }

    # this should run after the certificate is created
    # custom_domain {
    #   name                     = var.domain_name
    #   certificate_id           = azurerm_container_app_environment_certificate.cert.id
    #   certificate_binding_type = "SniEnabled"
    # }
  }

  lifecycle {
    ignore_changes = [ingress.0.custom_domain]
  }
}