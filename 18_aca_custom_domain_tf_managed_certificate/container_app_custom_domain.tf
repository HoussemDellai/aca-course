
# Error: parsing "/subscriptions/dcef7009-6b94-4382-afdc-17eb160d709a/resourceGroups/rg-aca-custom-domain-managed-cert-18/providers/Microsoft.App/managedEnvironments/aca-environment/managedCertificates/azure-aca-app.com": parsing segment "staticCertificates": parsing the Certificate ID: the segment at position 8 didn't match
# │ Expected a Certificate ID that matched:
# │ > /subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/example-resource-group/providers/Microsoft.App/managedEnvironments/managedEnvironmentName/certificates/certificateName
# │ However this value was provided:
# │ > /subscriptions/dcef7009-6b94-4382-afdc-17eb160d709a/resourceGroups/rg-aca-custom-domain-managed-cert-18/providers/Microsoft.App/managedEnvironments/aca-environment/managedCertificates/azure-aca-app.com
# │ The parsed Resource ID was missing a value for the segment at position 8
# │ (which should be the literal value "certificates").
# Managed Certificate
resource "azurerm_container_app_custom_domain" "custom-domain" {
  name                     = var.custom_domain_name
  container_app_id         = azurerm_container_app.inspactor-gadget.id
  certificate_binding_type = "SniEnabled"
  #   container_app_environment_certificate_id = azapi_resource.managed_certificate.id # azurerm_container_app_environment_certificate.cert.id

  lifecycle {
    // When using an Azure created Managed Certificate these values must be added to ignore_changes to prevent resource recreation.
    ignore_changes = [
      certificate_binding_type,
      container_app_environment_certificate_id
    ]
  }

  depends_on = [
    azurerm_dns_a_record.dns_a_record_aca_app,
    azurerm_dns_txt_record.dns_txt_record
  ]
}

resource "azapi_resource" "managed_certificate" {
  type      = "Microsoft.App/managedEnvironments/managedCertificates@2024-10-02-preview"
  parent_id = azurerm_container_app_environment.env.id
  name      = var.custom_domain_name
  location  = azurerm_container_app_environment.env.location

  body = {
    properties = {
      domainControlValidation = "HTTP"
      subjectName             = var.custom_domain_name
    }
  }

  depends_on = [ azurerm_container_app_custom_domain.custom-domain ]
}

# resource "azapi_update_resource" "bind_managed_certificate" {
#   type        = "Microsoft.App/containerapps@2024-10-02-preview"
#   resource_id = azurerm_container_app.inspactor-gadget.id

#   body = {
#     properties = {
#       configuration = {
#         ingress = {
#           customDomains = [
#             {
#               name          = var.custom_domain_name
#               certificateId = azapi_resource.managed_certificate.id
#               bindingType   = "SniEnabled"
#             }
#           ]
#         }
#       }
#     }
#   }

#   depends_on = [ azapi_resource.managed_certificate ]
# }
#  "customDomains": [
#                   {
#                       "name": "azure-aca-app.com",
#                       "certificateId": "[resourceId('Microsoft.App/managedEnvironments/managedCertificates', parameters('managedEnvironments_aca_environment_name'), 'azure-aca-app.com-aca-envi-250205150225')]",
#                       "bindingType": "SniEnabled"
#                   }
#               ],

# # test
# resource "azurerm_container_app_custom_domain" "custom-domain" {
#   name                                     = var.custom_domain_name # trimsuffix(trimprefix(azurerm_dns_txt_record.dns_txt_record.fqdn, "asuid."), ".") # trimprefix(azurerm_dns_txt_record.dns_txt_record.fqdn, "asuid.")
#   container_app_id                         = azurerm_container_app.inspactor-gadget.id
#   # container_app_environment_certificate_id = azapi_resource.certificate.id # azurerm_container_app_environment_certificate.cert.id
#   certificate_binding_type                 = "SniEnabled"

#   depends_on = [
#     azurerm_dns_a_record.dns_a_record_aca_app,
#     azurerm_dns_txt_record.dns_txt_record
#   ]
# }
