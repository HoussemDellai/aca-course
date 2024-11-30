$RESOURCE_GROUP="rg-container-apps-pe"
$LOCATION="swedencentral"
$ENVIRONMENT_NAME="aca-environment"
$CONTAINERAPP_NAME="container-app"
$VNET_NAME="vnet-aca"
$SUBNET_NAME="snet-pe"
$PRIVATE_ENDPOINT="pe-aca"
$PRIVATE_ENDPOINT_CONNECTION="pe-connection"
$PRIVATE_DNS_ZONE="privatelink.${LOCATION}.azurecontainerapps.io"
$DNS_LINK="vnet-dns-link"

az group create --name $RESOURCE_GROUP --location $LOCATION

az network vnet create --resource-group $RESOURCE_GROUP --name $VNET_NAME --location $LOCATION --address-prefix 10.0.0.0/16

az network vnet subnet create --resource-group $RESOURCE_GROUP --vnet-name $VNET_NAME --name $SUBNET_NAME --address-prefixes 10.0.0.0/21

$SUBNET_ID=$(az network vnet subnet show --resource-group $RESOURCE_GROUP --vnet-name $VNET_NAME --name $SUBNET_NAME --query "id" --output tsv)

az containerapp env create --name $ENVIRONMENT_NAME --resource-group $RESOURCE_GROUP --location $LOCATION

$ENVIRONMENT_ID=$(az containerapp env show --resource-group $RESOURCE_GROUP --name $ENVIRONMENT_NAME --query "id" --output tsv)

az containerapp env update --id $ENVIRONMENT_ID --public-network-access Disabled

az network private-endpoint create --resource-group $RESOURCE_GROUP --location $LOCATION --name $PRIVATE_ENDPOINT --subnet $SUBNET_ID --private-connection-resource-id $ENVIRONMENT_ID --connection-name $PRIVATE_ENDPOINT_CONNECTION --group-id managedEnvironments

$PRIVATE_ENDPOINT_IP_ADDRESS=$(az network private-endpoint show --name $PRIVATE_ENDPOINT --resource-group $RESOURCE_GROUP --query 'customDnsConfigs[0].ipAddresses[0]' --output tsv)

$DNS_RECORD_NAME = (az containerapp env show --id $ENVIRONMENT_ID --query 'properties.defaultDomain' --output tsv) -replace '\..*'
# $DNS_RECORD_NAME=$(az containerapp env show --id $ENVIRONMENT_ID --query 'properties.defaultDomain' --output tsv | sed 's/\..*//')

az network private-dns zone create --resource-group $RESOURCE_GROUP --name $PRIVATE_DNS_ZONE

az network private-dns link vnet create --resource-group $RESOURCE_GROUP --zone-name $PRIVATE_DNS_ZONE --name $DNS_LINK --virtual-network $VNET_NAME --registration-enabled false

az network private-dns record-set a add-record --resource-group $RESOURCE_GROUP --zone-name $PRIVATE_DNS_ZONE --record-set-name $DNS_RECORD_NAME --ipv4-address $PRIVATE_ENDPOINT_IP_ADDRESS

az containerapp up --name $CONTAINERAPP_NAME --resource-group $RESOURCE_GROUP --location $LOCATION --environment $ENVIRONMENT_NAME --image mcr.microsoft.com/k8se/quickstart:latest --target-port 80 --ingress external --query properties.configuration.ingress.fqdn

az vm create `
  --resource-group $RESOURCE_GROUP `
  --name vm-linux `
  --image canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest `
  --size Standard_D2as_v5 `
  --public-ip-address '""' `
  --vnet-name $VNET_NAME `
  --subnet $SUBNET_NAME `
  --admin-username "azureuser" `
  --admin-password "@Aa123456789"
# az vm create --resource-group $RESOURCE_GROUP --name $VM_NAME --image Win2022Datacenter --public-ip-address "" --vnet-name $VNET_NAME --subnet $SUBNET_NAME --admin-username azureuser