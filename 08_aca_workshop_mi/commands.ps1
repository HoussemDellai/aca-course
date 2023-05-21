# Azure Container Apps lab

$RESOURCE_GROUP="rg-containerapps-album-qa"
$LOCATION="westeurope"
$ACA_ENVIRONMENT="containerapps-env-album"
$ACA_BACKEND_API="album-api"
$ACA_FRONTEND_UI="album-ui"
$ACR_NAME="acracaalbums013579"
$IDENTITY="identity-aca-acr"

# Create a resource group

az group create `
         --name $RESOURCE_GROUP `
         --location $LOCATION

# Create an Azure Container Registry

az acr create `
       --resource-group $RESOURCE_GROUP `
       --name $ACR_NAME `
       --sku Basic `
       --admin-enabled false

# Build the container with ACR

az acr build --registry $ACR_NAME --image $ACA_BACKEND_API ..\backend_api\backend_api_csharp\

# Create a Container Apps environment

az containerapp env create `
                --name $ACA_ENVIRONMENT `
                --resource-group $RESOURCE_GROUP `
                --location $LOCATION

# Create an identity for the container app

az identity create `
            --resource-group $RESOURCE_GROUP `
            --name $IDENTITY

# Get Identity Client ID

$IDENTITY_CLIENT_ID=$(az identity show --resource-group $RESOURCE_GROUP --name $IDENTITY --query clientId -o tsv)

$ACR_ID=$(az acr show `
        --resource-group $RESOURCE_GROUP `
        --name $ACR_NAME `
        --query id)

# Assign RBAC role ACRpull to the identity

az role assignment create `
        --role AcrPull `
        --assignee $IDENTITY_CLIENT_ID `
        --scope $ACR_ID

# Get identity's resource ID

$IDENTITY_RESOURCE_ID=$(az identity show --resource-group $RESOURCE_GROUP --name $IDENTITY --query id -o tsv)

echo $IDENTITY_RESOURCE_ID

# Deploy your backend image to a container app

az containerapp create `
                --name $ACA_BACKEND_API `
                --resource-group $RESOURCE_GROUP `
                --environment $ACA_ENVIRONMENT `
                --image $ACR_NAME'.azurecr.io/'$ACA_BACKEND_API `
                --target-port 3500 `
                --ingress 'internal' `
                --registry-server $ACR_NAME'.azurecr.io' `
                --user-assigned $IDENTITY_RESOURCE_ID `
                --registry-identity $IDENTITY_RESOURCE_ID `
                --query properties.configuration.ingress.fqdn

# Build the front end application

az acr build --registry $ACR_NAME --image $ACA_FRONTEND_UI ..\frontend_ui\

# Communicate between container apps

$API_BASE_URL=$(az containerapp show --resource-group $RESOURCE_GROUP --name $ACA_BACKEND_API --query properties.configuration.ingress.fqdn -o tsv)

echo $API_BASE_URL

# Deploy front end application

az containerapp create `
                --name $ACA_FRONTEND_UI `
                --resource-group $RESOURCE_GROUP `
                --environment $ACA_ENVIRONMENT `
                --image $ACR_NAME'.azurecr.io/'$ACA_FRONTEND_UI  `
                --target-port 3000 `
                --env-vars API_BASE_URL=https://$API_BASE_URL `
                --ingress 'external' `
                --registry-server $ACR_NAME'.azurecr.io' `
                --user-assigned $IDENTITY_RESOURCE_ID `
                --registry-identity $IDENTITY_RESOURCE_ID `
                --query properties.configuration.ingress.fqdn

# Clean up resources

# az group delete --name $RESOURCE_GROUP --yes --no-wait
