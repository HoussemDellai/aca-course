# Secure Container Apps with Application Gateway and HTTPS

This demonstration shows how to secure access to Container Apps using Azure Application Gateway and TLS certificate saved in Key vault for HTTPS.

![](images/architecture.png)

To deploy this architecture using terraform:

```
terraform init
terraform plan -out tfplan
terraform apply tfplan
```

The following resources will be created:

![](images/resources.png)

In addition to an Internal (private) Load Balancer:

![](images/ilb.png)