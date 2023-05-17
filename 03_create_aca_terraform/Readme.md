# Deploying Container Apps using Terraform

This lab will walk you through the deployment of Azure Container Apps using Terraform configuration file.
The terraform config in `main.tf` file will create the following resources:
1. Resource group
2. Azure Container Apps Environment
3. Azure Container Apps that deploys the container image from MCR registry: `mcr.microsoft.com/azuredocs/containerapps-helloworld:latest`.

To deploy this config, you need to cd into the folder where you have the `main.tf` file. Then run the following commands.

```shell
terraform init

terraform plan -out tfplan

terraform apply tfplan
```