locals {
  certificate_name         = replace(var.custom_domain_name, ".", "-")
  appgw_private_ip_address = "10.0.0.10"

  backend_address_pool_name              = "backend-address-pool"
  frontend_port_http_name                = "frontend-port-http"
  frontend_port_https_name               = "frontend-port-https"
  frontend_ip_configuration_name         = "frontend-ip-configuration"
  frontend_private_ip_configuration_name = "frontend-private-ip-configuration"
  backend_http_settings_https            = "backend-http-settings-https"
  listener_http_name                     = "listener-http"
  listener_https_name                    = "listener-https"
  request_routing_rule_http_name         = "request-routing-rule-http"
  request_routing_rule_https_name        = "request-routing-rule-https"
  redirect_configuration_name            = "redirect-configuration"
  https_probe_name                       = "http-health-probe"
}