# Azure Container Apps lab

$RESOURCE_GROUP = "rg-containerapps-album"
$LOCATION = "westeurope"
$ACA_ENVIRONMENT = "containerapps-env-album"
$ACA_BACKEND_API="album-api"
$ACA_FRONTEND_UI="album-ui"
$GITHUB_USERNAME = "houssemdellai"

$ACR_NAME = "acaalbums"+$GITHUB_USERNAME

git clone https://github.com/$GITHUB_USERNAME/containerapps-albumapi-csharp.git

cd \containerapps-albumapi-csharp\src

Create an Azure Container Registry

az group create `
         --name $RESOURCE_GROUP `
         --location $LOCATION

Create an Azure Container Registry

az acr create `
       --resource-group $RESOURCE_GROUP `
       --name $ACR_NAME `
       --sku Basic `
       --admin-enabled true

Build the container with ACR

az acr build --registry $ACR_NAME --image $ACA_BACKEND_API .

Create a Container Apps environment

az containerapp env create `
                --name $ACA_ENVIRONMENT `
                --resource-group $RESOURCE_GROUP `
                --location $LOCATION

Deploy your image to a container app

az containerapp create `
                --name $ACA_BACKEND_API `
                --resource-group $RESOURCE_GROUP `
                --environment $ACA_ENVIRONMENT `
                --image $ACR_NAME'.azurecr.io/'$ACA_BACKEND_API `
                --target-port 3500 `
                --ingress 'external' `
                --registry-server $ACR_NAME'.azurecr.io' `
                --query properties.configuration.ingress.fqdn