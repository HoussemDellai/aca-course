# resource "azapi_update_resource" "configure_custom_domain" {
#   type        = "Microsoft.App/containerApps@2023-05-01"
#   resource_id = azurerm_container_app.aca.id

#   body = jsonencode({
#     properties = {
#       configuration = {
#         ingress = {
#           customDomains = [
#             {
#               name          = azurerm_dns_zone.dns_zone.name,
#               certificateId = azurerm_container_app_environment_certificate.cert.id,
#               bindingType   = "SniEnabled"
#             }
#           ]
#         }
#       }
#     }
#   })
  
#   depends_on = [ azurerm_dns_txt_record.dns_txt_record ]
# }