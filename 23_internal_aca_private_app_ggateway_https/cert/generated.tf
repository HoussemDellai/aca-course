# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform
resource "azurerm_application_gateway" "main" {
  enable_http2                      = true
  fips_enabled                      = false
  firewall_policy_id                = null
  force_firewall_policy_association = false
  location                          = "swedencentral"
  name                              = "appgw-portal2"
  resource_group_name               = "rg-aca-dns-appgw-23"
  tags                              = {}
  zones                             = ["1"]
  backend_address_pool {
    fqdns        = ["inspector-gadget.redsky-0d25d0df.swedencentral.azurecontainerapps.io"]
    ip_addresses = []
    name         = "backendpool"
  }
  backend_http_settings {
    affinity_cookie_name                = "ApplicationGatewayAffinity"
    cookie_based_affinity               = "Disabled"
    host_name                           = null
    name                                = "backendsettings"
    path                                = null
    pick_host_name_from_backend_address = true
    port                                = 80
    probe_name                          = null
    protocol                            = "Http"
    request_timeout                     = 20
    trusted_root_certificate_names      = []
  }
  frontend_ip_configuration {
    name                            = "appGwPrivateFrontendIpIPv4"
    private_ip_address              = "10.0.1.20"
    private_ip_address_allocation   = "Static"
    private_link_configuration_name = null
    public_ip_address_id            = null
    subnet_id                       = "/subscriptions/38977b70-47bf-4da5-a492-88712fce8725/resourceGroups/rg-aca-dns-appgw-23/providers/Microsoft.Network/virtualNetworks/vnet-internal/subnets/subnet-appgw"
  }
  frontend_port {
    name = "port_443"
    port = 443
  }
  frontend_port {
    name = "port_80"
    port = 80
  }
  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = "/subscriptions/38977b70-47bf-4da5-a492-88712fce8725/resourceGroups/rg-aca-dns-appgw-23/providers/Microsoft.Network/virtualNetworks/vnet-internal/subnets/subnet-appgw"
  }
  http_listener {
    firewall_policy_id             = null
    frontend_ip_configuration_name = "appGwPrivateFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "aca-app-01.com"
    host_names                     = []
    name                           = "listener-https"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "aca-app-01.com"
    ssl_profile_name               = null
  }
  http_listener {
    firewall_policy_id             = null
    frontend_ip_configuration_name = "appGwPrivateFrontendIpIPv4"
    frontend_port_name             = "port_80"
    host_name                      = "aca-app-01.com"
    host_names                     = []
    name                           = "listener"
    protocol                       = "Http"
    require_sni                    = false
    ssl_certificate_name           = null
    ssl_profile_name               = null
  }
  request_routing_rule {
    backend_address_pool_name   = "backendpool"
    backend_http_settings_name  = "backendsettings"
    http_listener_name          = "listener"
    name                        = "rule1"
    priority                    = 100
    redirect_configuration_name = null
    rewrite_rule_set_name       = null
    rule_type                   = "Basic"
    url_path_map_name           = null
  }
  request_routing_rule {
    backend_address_pool_name   = "backendpool"
    backend_http_settings_name  = "backendsettings"
    http_listener_name          = "listener-https"
    name                        = "rule-https"
    priority                    = 200
    redirect_configuration_name = null
    rewrite_rule_set_name       = null
    rule_type                   = "Basic"
    url_path_map_name           = null
  }
  sku {
    capacity = 1
    name     = "Standard_v2"
    tier     = "Standard_v2"
  }
  # ssl_certificate {} # sensitive
}
