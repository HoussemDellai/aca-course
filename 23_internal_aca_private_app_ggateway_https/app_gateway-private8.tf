# locals {
#   frontend_private_ip_configuration_name = "frontend-private-ip-configuration"
# }

resource "azurerm_public_ip" "pip-appgateway8" {
  name                = "pip-appgateway8"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "appgateway-private8" {
  name                = "appgateway-private8"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = "Standard_v2" # "WAF_v2"
    tier     = "Standard_v2" # "WAF_v2"
    # capacity = 1
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

  frontend_port {
    name = local.frontend_port_http_name
    port = 80
  }

  frontend_port {
    name = local.frontend_port_https_name
    port = 443
  }

  # public IP config
  # for appgw to retrieve cert from public Keyvault
  # not needed if keyvault is available with PLS
  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pip-appgateway8.id
  }

  # private IP config
  frontend_ip_configuration {
    name                          = local.frontend_private_ip_configuration_name
    subnet_id                     = azurerm_subnet.subnet-appgw.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.18"
  }

  backend_address_pool {
    name  = local.backend_address_pool_name
    fqdns = [azurerm_container_app.app.latest_revision_fqdn]
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
    # path                                = "/path1/"
  }

  http_listener {
    name                           = local.listener_http_name
    frontend_ip_configuration_name = local.frontend_private_ip_configuration_name # 
    frontend_port_name             = local.frontend_port_http_name
    protocol                       = "Http"
    # host_name 
    # host_names
  }

  http_listener {
    name                           = local.listener_https_name
    frontend_ip_configuration_name = local.frontend_private_ip_configuration_name # 
    frontend_port_name             = local.frontend_port_https_name
    protocol                       = "Https"
    ssl_certificate_name           = var.custom_domain_name
    # host_name 
    # host_names
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

  autoscale_configuration {
    min_capacity = "1"
    max_capacity = "2"
  }
}
