# Exposing privately Container Apps using custom domain names

This demonstration shows how to:
1) Privately access internal `Container Apps` using custom domain names.
2) Secure access to `Container Apps` using `Azure Application Gateway` and TLS certificate saved in `Key vault` for HTTPS.

![](images/architecture.png)

To deploy this architecture using `terraform`:

```
terraform init
terraform plan -out tfplan
terraform apply tfplan
```

The following resources will be created:

![](images/resources.png)

In addition to an Internal (private) Load Balancer:

![](images/ilb.png)

## Notes

For `Application Gateway` to be able to get certificate from `Key vault`, it needs to network access that can be provided through one of these two solutions:
1) Attaching a `Public IP` to the `App Gateway`
2) Provide egress solution like `NAT Gateway` or `NVA` like `Azure Firewall`