$RG="rg-aca-service-connector-30"
$LOCATION="swedencentral"
$ACA_ENV="aca-environment"

az group create -n $RG -l $LOCATION

az containerapp env create -n $ACA_ENV -g $RG -l $LOCATION

az storage account create -n storaca135 -g $RG -l $LOCATION --sku Standard_LRS

az storage container create --account-name storaca135 -n container01 --auth-mode login

az storage container create --account-name storaca135 -n container02 --auth-mode login

az containerapp up -n app-python -g $RG --environment $ACA_ENV --source ./app-python

# az containerapp connection create storage-blob --system-identity --account storaca135 -n conn01 -g $RG
# az identity create -n id-aca -g $RG

