The binding of the certificate should run after the creation.

```hcl
    custom_domain {
      name                     = var.domain_name
      certificate_id           = azurerm_container_app_environment_certificate.cert.id
      certificate_binding_type = "SniEnabled"
    }
```

A TXT record (from ACA app) should be added to the DNS Zone.

Deployment steps:

1. Disable `custom_domain` block with container app
2. Deploy infra
2. Enable `custom_domain`