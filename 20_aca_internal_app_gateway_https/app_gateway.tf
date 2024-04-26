locals {
  backend_address_pool_name       = "backend-address-pool"
  frontend_port_http_name         = "frontend-port-http"
  frontend_port_https_name        = "frontend-port-https"
  frontend_ip_configuration_name  = "frontend-ip-configuration"
  backend_http_settings_https     = "backend-http-settings-https"
  listener_http_name              = "listener-http"
  listener_https_name             = "listener-https"
  request_routing_rule_http_name  = "request-routing-rule-http"
  request_routing_rule_https_name = "request-routing-rule-https"
  redirect_configuration_name     = "redirect-configuration"
  https_probe_name                 = "http-health-probe"
}

resource "azurerm_public_ip" "pip-appgateway" {
  name                = "pip-appgateway"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "appgateway" {
  name                = "appgateway"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = "Standard_v2" # "WAF_v2"
    tier     = "Standard_v2" # "WAF_v2"
    capacity = 1
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.identity-appgw.id]
  }

  ssl_certificate {
    name                = var.custom_domain_name
    key_vault_secret_id = azurerm_key_vault_certificate.local_domain_certs.secret_id
  }

  gateway_ip_configuration {
    name      = "appgateway-ip-configuration"
    subnet_id = azurerm_subnet.subnet-appgw.id
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pip-appgateway.id
  }

  frontend_port {
    name = local.frontend_port_http_name
    port = 80
  }

  frontend_port {
    name = local.frontend_port_https_name
    port = 443
  }

  backend_address_pool {
    name = local.backend_address_pool_name
    fqdns = [ azurerm_container_app.app.latest_revision_fqdn ]
  }

  backend_http_settings {
    name                                = local.backend_http_settings_https
    port                                = 443
    protocol                            = "Https"
    cookie_based_affinity               = "Disabled"
    pick_host_name_from_backend_address = true # false
    affinity_cookie_name                = "ApplicationGatewayAffinity"
    request_timeout                     = 20
    probe_name                          = local.https_probe_name
  }

  http_listener {
    name                           = local.listener_http_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_http_name
    protocol                       = "Http"
  }

  http_listener {
    name                           = local.listener_https_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_https_name
    protocol                       = "Https"
    ssl_certificate_name           = var.custom_domain_name
  }

  # HTTP Routing Rule - HTTP to HTTPS Redirect
  request_routing_rule {
    name                        = local.request_routing_rule_http_name
    rule_type                   = "Basic"
    priority                    = 1
    http_listener_name          = local.listener_http_name
    redirect_configuration_name = local.redirect_configuration_name
  }

  # HTTPS Routing Rule - Port 443
  request_routing_rule {
    name                       = local.request_routing_rule_https_name
    rule_type                  = "Basic"
    priority                   = 2
    http_listener_name         = local.listener_https_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.backend_http_settings_https
  }

  redirect_configuration {
    name                 = local.redirect_configuration_name
    redirect_type        = "Permanent" # Permanent, Temporary, Found and SeeOther
    target_listener_name = local.listener_https_name
    include_path         = true
    include_query_string = true
  }

  probe {
    name                                      = local.https_probe_name
    protocol                                  = "Https"
    pick_host_name_from_backend_http_settings = true
    path                                      = "/"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    minimum_servers                           = 0

    match {
      status_code = ["200-399"]
    }
  }
}