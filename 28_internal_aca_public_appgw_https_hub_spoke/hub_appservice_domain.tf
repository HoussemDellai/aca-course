# You should use a Pay-As-You-Go azure subscription to be able to create Azure App Service Domain.
# MSDN/VisualStudio and Free Azure subscriptions doesn't work.
module "appservice_domain" {
  source  = "HoussemDellai/appservice-domain/azapi" # if calling module from Terraform Registry
  version = "2.1.0"

  custom_domain_name = var.custom_domain_name
  resource_group_id  = azurerm_resource_group.rg-hub.id
  dns_zone_id        = azurerm_dns_zone.dns-zone-apps.id
}