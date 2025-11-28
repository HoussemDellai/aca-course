# You should use a Pay-As-You-Go azure subscription to be able to create Azure App Service Domain.
# MSDN/VisualStudio and Free Azure subscriptions doesn't work.

# App Service Domain
# REST API reference: https://docs.microsoft.com/en-us/rest/api/appservice/domains/createorupdate
resource "azapi_resource" "appservice_domain" {
  type                      = "Microsoft.DomainRegistration/domains@2024-04-01"
  name                      = var.custom_domain_name
  parent_id                 = azurerm_resource_group.rg-hub.id
  location                  = "global"
  schema_validation_enabled = true
  response_export_values    = ["*"] # ["id", "name", "properties.nameServers"]

  body = {

    properties = {
      dnsType   = "AzureDns"
      dnsZoneId = azurerm_dns_zone.dns-zone-apps.id
      autoRenew = false
      privacy   = false

      consent = {
        agreementKeys = ["DNRA"]
        agreedBy      = var.agreedby_ip_v6
        agreedAt      = var.agreedat_datetime
      }

      contactAdmin = {
        nameFirst = var.contact.nameFirst
        nameLast  = var.contact.nameLast
        email     = var.contact.email
        phone     = var.contact.phone

        addressMailing = {
          address1   = var.contact.addressMailing.address1
          city       = var.contact.addressMailing.city
          state      = var.contact.addressMailing.state
          country    = var.contact.addressMailing.country
          postalCode = var.contact.addressMailing.postalCode
        }
      }

      contactRegistrant = {
        nameFirst = var.contact.nameFirst
        nameLast  = var.contact.nameLast
        email     = var.contact.email
        phone     = var.contact.phone

        addressMailing = {
          address1   = var.contact.addressMailing.address1
          city       = var.contact.addressMailing.city
          state      = var.contact.addressMailing.state
          country    = var.contact.addressMailing.country
          postalCode = var.contact.addressMailing.postalCode
        }
      }

      contactBilling = {
        nameFirst = var.contact.nameFirst
        nameLast  = var.contact.nameLast
        email     = var.contact.email
        phone     = var.contact.phone

        addressMailing = {
          address1   = var.contact.addressMailing.address1
          city       = var.contact.addressMailing.city
          state      = var.contact.addressMailing.state
          country    = var.contact.addressMailing.country
          postalCode = var.contact.addressMailing.postalCode
        }
      }

      contactTech = {
        nameFirst = var.contact.nameFirst
        nameLast  = var.contact.nameLast
        email     = var.contact.email
        phone     = var.contact.phone

        addressMailing = {
          address1   = var.contact.addressMailing.address1
          city       = var.contact.addressMailing.city
          state      = var.contact.addressMailing.state
          country    = var.contact.addressMailing.country
          postalCode = var.contact.addressMailing.postalCode
        }
      }
    }
  }
}

variable "agreedby_ip_v6" {
  type    = string
  default = "2a04:cec0:11d9:24c8:8898:3820:8631:d83"
}

variable "agreedat_datetime" {
  type    = string
  default = "2024-01-01T9:00:00.000Z"
}

variable "contact" {
  type = object({
    nameFirst = string
    nameLast  = string
    email     = string
    phone     = string
    addressMailing = object({
      address1   = string
      city       = string
      state      = string
      country    = string
      postalCode = string
    })
  })
  default = {
    nameFirst = "John"
    nameLast  = "Doe"
    email     = "john.doe@example.com"
    phone     = "+1.762954328"
    addressMailing = {
      address1   = "123 Main St"
      city       = "New York"
      state      = "New York"
      country    = "US"
      postalCode = "12345"
    }
  }
}

# module "appservice_domain" {
#   source  = "HoussemDellai/appservice-domain/azapi" # if calling module from Terraform Registry
#   version = "2.1.0"

#   custom_domain_name = var.custom_domain_name
#   resource_group_id  = azurerm_resource_group.rg-hub.id
#   dns_zone_id        = azurerm_dns_zone.dns-zone-apps.id
# }
