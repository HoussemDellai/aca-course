data "azurerm_client_config" "current" {}

resource "random_string" "random" {
  length  = 5
  special = false
  lower   = true
  upper   = false
}

resource "azurerm_key_vault" "keyvault" {
  name                       = "kv-aca-cert-${random_string.random.result}"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  enable_rbac_authorization  = true
}

resource "azurerm_key_vault_certificate" "cert-self-signed" {
  name         = replace(var.custom_domain_name, ".", "-")
  key_vault_id = azurerm_key_vault.keyvault.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]
      key_usage = [
        "digitalSignature",
        "keyEncipherment"
      ]
      subject            = "CN=*.${var.custom_domain_name}"
      validity_in_months = 12

      subject_alternative_names {
        dns_names = ["*.${var.custom_domain_name}"]
      }
    }
  }

  depends_on = [azurerm_role_assignment.role-certificates-officer]
}

resource "azurerm_role_assignment" "role-certificates-officer" {
  role_definition_name = "Key Vault Certificates Officer"
  principal_id         = data.azurerm_client_config.current.object_id
  scope                = azurerm_key_vault.keyvault.id
}
