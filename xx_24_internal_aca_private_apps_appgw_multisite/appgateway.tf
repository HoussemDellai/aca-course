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

  dynamic "ssl_certificate" {
    for_each = var.apps

    content {
      name = ssl_certificate.value.certificate_name
      # name                = "${ssl_certificate.key}.${var.sub_domain_name}"
      key_vault_secret_id = azurerm_key_vault_certificate.cert[ssl_certificate.key].secret_id
    }
  }

  gateway_ip_configuration {
    name      = "appgateway-ip-configuration"
    subnet_id = azurerm_subnet.snet-appgw.id
  }

  frontend_ip_configuration {
    name                          = local.frontend_private_ip_configuration_name
    private_ip_address_allocation = "Static"
    subnet_id                     = azurerm_subnet.snet-appgw.id
    private_ip_address            = local.appgw_private_ip_address
  }

  frontend_port {
    name = local.frontend_port_http_name
    port = 80
  }

  frontend_port {
    name = local.frontend_port_https_name
    port = 443
  }

  dynamic "backend_address_pool" {
    for_each = var.apps

    content {
      name  = "${local.backend_address_pool_name}-${backend_address_pool.key}"
      fqdns = [azurerm_container_app.app[backend_address_pool.key].ingress.0.fqdn]
    }
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

  dynamic "http_listener" {
    for_each = var.apps

    content {
      name                           = "${local.listener_http_name}-${http_listener.key}"
      frontend_ip_configuration_name = local.frontend_private_ip_configuration_name
      frontend_port_name             = local.frontend_port_http_name
      protocol                       = "Http"
      host_name                      = http_listener.value.sub_domain_name # var.sub_domain_name
    }
  }

  dynamic "http_listener" {
    for_each = var.apps

    content {
      name                           = "${local.listener_https_name}-${http_listener.key}"
      frontend_ip_configuration_name = local.frontend_private_ip_configuration_name
      frontend_port_name             = local.frontend_port_https_name
      protocol                       = "Https"
      ssl_certificate_name           = http_listener.value.certificate_name   # local.certificate_name
      host_name                      = http_listener.value.sub_domain_name # var.sub_domain_name
    }
  }

  # HTTP Routing Rule - Port 80
  dynamic "request_routing_rule" {
    for_each = var.apps

    content {
      name                        = "${local.request_routing_rule_http_name}-${request_routing_rule.key}"
      rule_type                   = "Basic"
      priority                    = request_routing_rule.value.appgw_request_routing_rule_priority
      http_listener_name          = "${local.listener_http_name}-${request_routing_rule.key}" # local.listener_http_name
      redirect_configuration_name = "${local.redirect_configuration_name}-${request_routing_rule.key}" # local.redirect_configuration_name
    }
  }

  # HTTPS Routing Rule - Port 443
  dynamic "request_routing_rule" {
    for_each = var.apps

    content {
      name                       = "${local.request_routing_rule_https_name}-${request_routing_rule.key}"
      rule_type                  = "Basic"
      priority                   = sum([request_routing_rule.value.appgw_request_routing_rule_priority, 1])
      http_listener_name         = "${local.listener_https_name}-${request_routing_rule.key}"
      backend_address_pool_name  = "${local.backend_address_pool_name}-${request_routing_rule.key}" # local.backend_address_pool_name
      backend_http_settings_name = local.backend_http_settings_https
    }
  }

  dynamic "redirect_configuration" {
    for_each = var.apps

    content {
      name                 = "${local.redirect_configuration_name}-${redirect_configuration.key}"
      redirect_type        = "Permanent" # Permanent, Temporary, Found and SeeOther
      target_listener_name = "${local.listener_https_name}-${redirect_configuration.key}" # local.listener_https_name
      include_path         = true
      include_query_string = true
    }
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

  depends_on = [ azurerm_key_vault_certificate.cert ]
}
