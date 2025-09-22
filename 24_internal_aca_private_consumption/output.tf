output "aca_environment_platform_reserved_cidr" {
  value = azurerm_container_app_environment.env.platform_reserved_cidr
}

output "aca_environment_platform_reserved_dns_ip_address" {
  value = azurerm_container_app_environment.env.platform_reserved_dns_ip_address
}

output "aca_environment_static_ip_address" {
  value = azurerm_container_app_environment.env.static_ip_address
}

output "aca_environment_docker_bridge_cidr" {
  value = azurerm_container_app_environment.env.docker_bridge_cidr
}