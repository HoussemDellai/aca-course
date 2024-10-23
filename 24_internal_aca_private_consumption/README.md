# Internal Container Apps with Consumption plan

This demonstration shows that when you deploy `Azure Container Apps` in an `Internal` network with a `Consumption` plan:
1) ACA app can connect to VNET resources like VMs and Azure services like `Azure Key Vault`
2) Resources within the VNET can connect to ACA app

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

To deploy the `Azure Container Apps` in an `Internal` network, you will need to create at least one `Workload Profile`. If you don't need it, you can configure its scalability to be between 0 and 1. When it is not used, it will be always 0, so you won't be charged for it.