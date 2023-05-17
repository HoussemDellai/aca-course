# Creating a simple Azure Container Apps demo

In this tutorial, you create a secure Container Apps environment and deploy your first container app.
Through a series of Azure CLI commands, you will:
1. Create the environment variables for resource group, location and app name
2. Create new resource group
3. Create a new Container Apps Environment (by default, will create a Log Analytics)
4. Create a new Container Apps using a sample container image from MCR registry

```powershell
$RESOURCE_GROUP="rg-container-apps-demo"
$LOCATION="westeurope"
$CONTAINERAPPS_ENVIRONMENT="aca-environment"

az group create `
  --name $RESOURCE_GROUP `
  --location $LOCATION

az containerapp env create `
  --name $CONTAINERAPPS_ENVIRONMENT `
  --resource-group $RESOURCE_GROUP `
  --location $LOCATION

az containerapp create `
  --name my-container-app `
  --resource-group $RESOURCE_GROUP `
  --environment $CONTAINERAPPS_ENVIRONMENT `
  --image mcr.microsoft.com/azuredocs/containerapps-helloworld:latest `
  --target-port 80 `
  --ingress 'external'

az containerapp show `
  --name my-container-app `
  --resource-group $RESOURCE_GROUP `
  --query properties.configuration.ingress.fqdn
# "my-container-app.redwater-90523232.westeurope.azurecontainerapps.io"
```

Then you get the app URL/FQDN. You can open it in your browser to view the application running.

Then you can delete the created resources.

```powershell
az group delete --name $RESOURCE_GROUP --yes
```