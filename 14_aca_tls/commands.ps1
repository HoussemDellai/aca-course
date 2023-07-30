# 1. Create Container Apps Environment

# Define environment variables

$RG="rg-container-apps"
$LOCATION="westeurope"
$ACA_ENVIRONMENT="aca-environment"
$ACA_APP="my-container-app"
$DOMAIN_NAME="my-container-app-demo.com"
$SUBDOMAIN_NAME="app01"

# Create resource group

az group create --name $RG --location $LOCATION --output table

az containerapp env create -n $ACA_ENVIRONMENT -g $RG -l $LOCATION -o table

# 2. Create an application with ingress enabled

az containerapp create `
  --name $ACA_APP `
  --resource-group $RG `
  --environment $ACA_ENVIRONMENT `
  --image mcr.microsoft.com/azuredocs/containerapps-helloworld:latest `
  --target-port 80 `
  --ingress 'external' `
  --output table

# 3. Get the FQDN of the Container App and the IP address of the Container Apps Environment

# Get the FQDN of the Container App  
$FQDN=$(az containerapp show `
  --name $ACA_APP `
  --resource-group $RG `
  --query properties.configuration.ingress.fqdn `
  --output tsv)

echo $FQDN

# Get the IP address of the Container Apps Environment

$IP=$(az containerapp env show `
  --name $ACA_ENVIRONMENT `
  --resource-group $RG `
  --query properties.staticIp `
  --output tsv)

echo $IP

# Get the domain verification code

$DOMAIN_VERIFICATION_CODE=$(az containerapp show -n $ACA_APP -g $RG -o tsv --query "properties.customDomainVerificationId")

echo $DOMAIN_VERIFICATION_CODE

# 4. Create an App Service Domain

az appservice domain create `
   --resource-group $RG `
   --hostname $DOMAIN_NAME `
   --contact-info=@'contact_info.json' `
   --accept-terms

# This generates an app service domain and a Azure DNS Zone. The Azure DNS Zone is used to create DNS records for the domain.

# 5. Configure Custom Domain Names for Container App

# You have two options, either with CAME for a subdomain or with A record for APEX / root domain

# Option 1. Create DNS records in Azure DNS Zone [CNAME record]

az network dns record-set cname create `
   --name $SUBDOMAIN_NAME `
   --resource-group $RG `
   --zone-name $DOMAIN_NAME
#   {
#     "TTL": 3600,
#     "etag": "16da8900-d860-4333-a744-0079a7c22e46",
#     "fqdn": "www.my-container-app-demo.com.",
#     "id": "/subscriptions/82f6d75e-85f4-434a-ab74-5dddd9fa8910/resourceGroups/rg-container-apps/providers/Microsoft.Network/dnszones/my-container-app-demo.com/CNAME/www",
#     "name": "www",
#     "provisioningState": "Succeeded",
#     "resourceGroup": "rg-container-apps",
#     "targetResource": {},
#     "type": "Microsoft.Network/dnszones/CNAME"
#   }

az network dns record-set cname set-record `
   --record-set-name $SUBDOMAIN_NAME `
   --resource-group $RG `
   --zone-name $DOMAIN_NAME `
   --cname $FQDN
#   {
#     "CNAMERecord": {
#       "cname": "my-container-app.agreeablerock-8f2e2f19.westeurope.azurecontainerapps.io"
#     },
#     "TTL": 3600,
#     "etag": "4c0780c7-02d4-48a2-a7ad-deffbcfbf3d0",
#     "fqdn": "www.my-container-app-demo.com.",
#     "id": "/subscriptions/82f6d75e-85f4-434a-ab74-5dddd9fa8910/resourceGroups/rg-container-apps/providers/Microsoft.Network/dnszones/my-container-app-demo.com/CNAME/www",
#     "name": "www",
#     "provisioningState": "Succeeded",
#     "resourceGroup": "rg-container-apps",
#     "targetResource": {},
#     "type": "Microsoft.Network/dnszones/CNAME"
#   }

# Create a TXT record for domain verification

az network dns record-set txt create `
   --resource-group $RG `
   --zone-name $DOMAIN_NAME `
   --name "asuid.$SUBDOMAIN_NAME" 
#   {
#     "TTL": 3600,
#     "TXTRecords": [],
#     "etag": "1af3f809-f2a8-49d6-995a-511aff8a5434",
#     "fqdn": "asuid.my-container-app-demo.com.",
#     "id": "/subscriptions/82f6d75e-85f4-434a-ab74-5dddd9fa8910/resourceGroups/rg-container-apps/providers/Microsoft.Network/dnszones/my-container-app-demo.com/TXT/asuid",
#     "name": "asuid",
#     "provisioningState": "Succeeded",
#     "resourceGroup": "rg-container-apps",
#     "targetResource": {},
#     "type": "Microsoft.Network/dnszones/TXT"
#   }

az network dns record-set txt add-record `
   --resource-group $RG `
   --zone-name $DOMAIN_NAME `
   --record-set-name "asuid.$SUBDOMAIN_NAME" `
   --value $DOMAIN_VERIFICATION_CODE
#   {
#     "TTL": 3600,
#     "TXTRecords": [
#       {
#         "value": [
#           "5EB5439D8586817EB60FDE8449E3F1B71E96439447FA9C53144C8FB1985BA85D"
#         ]
#       }
#     ],
#     "etag": "7ec96bdd-ea03-44ba-95f9-65657d72c783",
#     "fqdn": "asuid.my-container-app-demo.com.",
#     "id": "/subscriptions/82f6d75e-85f4-434a-ab74-5dddd9fa8910/resourceGroups/rg-container-apps/providers/Microsoft.Network/dnszones/my-container-app-demo.com/TXT/asuid",
#     "name": "asuid",
#     "provisioningState": "Succeeded",
#     "resourceGroup": "rg-container-apps",
#     "targetResource": {},
#     "type": "Microsoft.Network/dnszones/TXT"
#   }


# Add the domain to your container app

az containerapp hostname add --hostname "$SUBDOMAIN_NAME.$DOMAIN_NAME" -g $RG -n $ACA_APP

# Configure the managed certificate and bind the domain to your container app

az containerapp hostname bind --hostname "$SUBDOMAIN_NAME.$DOMAIN_NAME" -g $RG -n $ACA_APP --environment $ACA_ENVIRONMENT --validation-method CNAME


# Option 2. Create DNS records in Azure DNS Zone [A record]

# Create an A record for the root domain

az network dns record-set a create `
   --name "@" `
   --resource-group $RG `
   --zone-name $DOMAIN_NAME

az network dns record-set a add-record `
   --record-set-name "@" `
   --resource-group $RG `
   --zone-name $DOMAIN_NAME `
   --ipv4-address $IP

# Create a TXT record for domain verification

az network dns record-set txt create `
   --resource-group $RG `
   --zone-name $DOMAIN_NAME `
   --name "asuid" 

az network dns record-set txt add-record `
   --resource-group $RG `
   --zone-name $DOMAIN_NAME `
   --record-set-name "asuid" `
   --value $DOMAIN_VERIFICATION_CODE

# Add the domain to your container app

az containerapp hostname add --hostname "$DOMAIN_NAME" -g $RG -n $ACA_APP

# Configure the managed certificate and bind the domain to your container app

az containerapp hostname bind --hostname $DOMAIN_NAME -g $RG -n $ACA_APP --environment $ACA_ENVIRONMENT --validation-method HTTP

# 6. Verify the domain

# Verify the domain by navigating to the domain name in a browser. You should see the default page for the container app.

echo "https://$DOMAIN_NAME" # if using A record with APEX / root domain

echo "https://$SUBDOMAIN_NAME.$DOMAIN_NAME" # if using CNAME with subdomain

# Clean up resources

az group delete --name $ACA_RG --yes --no-wait