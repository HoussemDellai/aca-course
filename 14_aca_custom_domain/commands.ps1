# 1. Create Container Apps Environment

# Define environment variables

$RG="rg-aca-demo"
$LOCATION="westeurope"
$ACA_ENVIRONMENT="aca-environment"
$ACA_APP="aca-app"
$DOMAIN_NAME="houssem-dellai-11.com" # .com, .net, .co.uk, .org, .nl, .in, .biz, .org.uk, and .co.in
$SUBDOMAIN_NAME="myapp"

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

# 3. Create an App Service Domain

az appservice domain create `
--resource-group $RG `
--hostname $DOMAIN_NAME `
--contact-info=@'contact_info.json' `
--accept-terms

# This generates an app service domain and a Azure DNS Zone. The Azure DNS Zone is used to create DNS records for the domain.

# 4. Get the FQDN of the Container App and the IP address of the Container Apps Environment

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

# 5. Configure Custom Domain Names for Container App

# You have two options, either with CAME for a subdomain or with A record for APEX / root domain

# Option 1. Create DNS records in Azure DNS Zone [CNAME record]

az network dns record-set cname create `
   --name $SUBDOMAIN_NAME `
   --resource-group $RG `
   --zone-name $DOMAIN_NAME

az network dns record-set cname set-record `
   --record-set-name $SUBDOMAIN_NAME `
   --resource-group $RG `
   --zone-name $DOMAIN_NAME `
   --cname $FQDN

# Create a TXT record for domain verification

az network dns record-set txt create `
   --resource-group $RG `
   --zone-name $DOMAIN_NAME `
   --name "asuid.$SUBDOMAIN_NAME" 

az network dns record-set txt add-record `
   --resource-group $RG `
   --zone-name $DOMAIN_NAME `
   --record-set-name "asuid.$SUBDOMAIN_NAME" `
   --value $DOMAIN_VERIFICATION_CODE

sleep 60

# 6. Add the domain to your container app

az containerapp hostname add --hostname "$SUBDOMAIN_NAME.$DOMAIN_NAME" -g $RG -n $ACA_APP

# Configure the managed certificate and bind the domain to your container app

az containerapp hostname bind --hostname "$SUBDOMAIN_NAME.$DOMAIN_NAME" -g $RG -n $ACA_APP --environment $ACA_ENVIRONMENT --validation-method CNAME

# 7. Verify the domain name

# Verify the domain by navigating to the domain name in a browser. You should see the default page for the container app.

echo "https://$SUBDOMAIN_NAME.$DOMAIN_NAME" # if using CNAME with subdomain


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

sleep 60

# 6. Add the domain to your container app

az containerapp hostname add --hostname "$DOMAIN_NAME" -g $RG -n $ACA_APP

# Configure the managed certificate and bind the domain to your container app

az containerapp hostname bind --hostname $DOMAIN_NAME -g $RG -n $ACA_APP --environment $ACA_ENVIRONMENT --validation-method HTTP

# 7. Verify the domain name

# Verify the domain by navigating to the domain name in a browser. You should see the default page for the container app.

echo "https://$DOMAIN_NAME" # if using A record with APEX / root domain

# Clean up resources

az group delete --name $RG --yes --no-wait