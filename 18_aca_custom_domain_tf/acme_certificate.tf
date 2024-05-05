# resource "tls_private_key" "private_key" {
#   algorithm = "RSA"
# }

# resource "acme_registration" "reg" {
#   account_key_pem = tls_private_key.private_key.private_key_pem
#   email_address   = "houssem.dellai@live.com"
# }

# resource "acme_certificate" "certificate" {
#   account_key_pem           = acme_registration.reg.account_key_pem
#   common_name               = azurerm_dns_zone.dns_zone.name   # var.domain_name # should run after azurerm_dns_zone.dns_zone is created
#   subject_alternative_names = [azurerm_dns_zone.dns_zone.name] # [var.domain_name]
#   certificate_p12_password  = "@Aa123456789"

#   dns_challenge {
#     provider = "azuredns"
#     config = {
#       AZURE_ENVIRONMENT     = "public" # one of: public, usgovernment, and china.
#       AZURE_TENANT_ID       = data.azurerm_client_config.current.tenant_id
#       AZURE_SUBSCRIPTION_ID = data.azurerm_client_config.current.subscription_id
#       AZURE_RESOURCE_GROUP  = azurerm_resource_group.rg.name
#       AZURE_ZONE_NAME       = azurerm_dns_zone.dns_zone.name
#       AZURE_PRIVATE_ZONE    = false # Set to true to use Azure Private DNS Zones and not public.
#       # AZURE_CLIENT_ID = "" # if not specified, it will use Azure CLI credentials
#       # AZURE_CLIENT_SECRET = ""
#     }
#   }

#   depends_on = [
#     azurerm_dns_zone.dns_zone,
#     azapi_resource.appservice_domain # technically not required, but added just to make sure it runs after the domain is created
#   ]
# }

# data "azurerm_client_config" "current" {}