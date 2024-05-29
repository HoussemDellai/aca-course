# Creating an Azure Container Apps for Backend and Frontend app

In this tutorial, you create a secure Container Apps environment and deploy your first container app.
Through a series of Azure CLI commands, you will:
1. Create the environment variables for resource group, location and app name
2. Create new resource group
3. Create a new Container Apps Environment (by default, will create a Log Analytics)
4. Create a new Container Apps using a sample container image from MCR registry

You will be using a sample backend and frontend container images available here: https://github.com/HoussemDellai?tab=packages.

For frontend app, you will use this image: `ghcr.io/houssemdellai/containerapps-album-frontend:v1`.

For backend app, you will use this image: `ghcr.io/houssemdellai/containerapps-album-backend:v1`.


```sh
$RESOURCE_GROUP="rg-container-apps"
$LOCATION="swedencentral"
$CONTAINERAPPS_ENVIRONMENT="aca-environment"
$CONTAINERAPPS_BACKEND="aca-app-backend-api"
$CONTAINERAPPS_FRONTEND="aca-app-frontend-ui"

# create resource group
az group create `
  --name $RESOURCE_GROUP `
  --location $LOCATION

# create ACA Environment
az containerapp env create `
  --name $CONTAINERAPPS_ENVIRONMENT `
  --resource-group $RESOURCE_GROUP `
  --location $LOCATION

# deploy backend container
az containerapp create `
  --name $CONTAINERAPPS_BACKEND `
  --resource-group $RESOURCE_GROUP `
  --environment $CONTAINERAPPS_ENVIRONMENT `
  --image ghcr.io/houssemdellai/containerapps-album-backend:v1 `
  --target-port 3500 `
  --ingress 'external'

# get backend API URL
$API_BASE_URL=$(az containerapp show `
  --name $CONTAINERAPPS_BACKEND `
  --resource-group $RESOURCE_GROUP `
  --query properties.configuration.ingress.fqdn `
  --output tsv)

echo $API_BASE_URL

# deploy frontend container
az containerapp create `
  --name $CONTAINERAPPS_FRONTEND `
  --resource-group $RESOURCE_GROUP `
  --environment $CONTAINERAPPS_ENVIRONMENT `
  --image ghcr.io/houssemdellai/containerapps-album-frontend:v1 `
  --target-port 3000 `
  --ingress 'external' `
  --env-vars API_BASE_URL=https://$API_BASE_URL

# get app URL/FQDN
az containerapp show `
  --name $CONTAINERAPPS_FRONTEND `
  --resource-group $RESOURCE_GROUP `
  --query properties.configuration.ingress.fqdn
# "my-container-app.redwater-90523232.westeurope.azurecontainerapps.io"
```

Then you get the app URL/FQDN. You can open it in your browser to view the application running.

Then you can delete the created resources.

```sh
az group delete --name $RESOURCE_GROUP --yes
```