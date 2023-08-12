# Deploying Container App using YAML file

# Creating ACA Environment using YAML file is not supported

# create environment variables

$RG="rg-aca"
$ACA_ENVIRONMENT="aca-environment"
$ACA_NAME="app-01"

# create resource group

az group create -n $RG -l westeurope -o table

# create ACA environment

az containerapp env create -n $ACA_ENVIRONMENT -g $RG -l westeurope -o table

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