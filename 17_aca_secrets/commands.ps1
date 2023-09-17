# Deploying Container App using YAML file

# Creating ACA Environment using YAML file is not supported

# create environment variables

$RG="rg-aca"
$ACA_ENVIRONMENT="aca-environment"
$ACA_NAME="aca-app"
$KV_NAME="kv-aca"
$MI_NAME="mi-aca"

# create resource group

az group create -n $RG -l westeurope -o table

# create ACA environment

az containerapp env create -n $ACA_ENVIRONMENT -g $RG -l westeurope -o table

# create Key vault

az keyvault create -n $KV_NAME -g $RG -l westeurope -o table

# create secret

az keyvault secret set --vault-name $KV_NAME --name "my-secret-01" --value "password123!"

$KV_ID=$(az keyvault show -n $KV_NAME -g $RG --query id -o tsv)

# create managed identity

az identity create -n $MI_NAME -g $RG -o table

$MI_PRINCIPAL_ID=$(az identity show -n "mi-aca" -g $RG --query principalId -o tsv)

# assign roles to managed identity

az role assignment create --role "Key Vault Secrets User" --assignee $MI_PRINCIPAL_ID --scope $KV_ID

# deploy containerapp using YAML file

# replace the environment resource ID in the YAML file

$ACA_ENVIRONMENT_ID=$(az containerapp env show -n $ACA_ENVIRONMENT -g $RG --query id -o tsv)

echo $ACA_ENVIRONMENT_ID

az containerapp create -n $ACA_NAME -g $RG --yaml aca_app.yaml

# test the app by accessing it through the browser

$ACA_FQDN=$(az containerapp show -n $ACA_NAME -g $RG --query properties.configuration.ingress.fqdn -o tsv)
echo $ACA_FQDN
Start-Process https://$ACA_FQDN

# export YAML configuration

az containerapp show -n $ACA_NAME -g $RG -o yaml > aca_app_exported.yaml