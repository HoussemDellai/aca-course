# Creating a CI/CD pipeline for Azure Container Apps

A lab for showing how to create CI/CD pipelines using Azure DevOps to deploy an app into Azure Container Apps.

![](images/architecture.png)

Create a Container Apps

```powershell
$RESOURCE_GROUP="rg-containerapps-azure-pipelines"
$LOCATION="westeurope"
$CONTAINERAPPS_ENVIRONMENT="aca-environment"
$CONTAINERAPPS_APP="album-backend-api"

az group create `
         --name $RESOURCE_GROUP `
         --location $LOCATION

az containerapp env create `
                --name $CONTAINERAPPS_ENVIRONMENT `
                --resource-group $RESOURCE_GROUP `
                --location $LOCATION

az containerapp create `
                --name $CONTAINERAPPS_APP `
                --resource-group $RESOURCE_GROUP `
                --environment $CONTAINERAPPS_ENVIRONMENT `
                --image mcr.microsoft.com/azuredocs/containerapps-helloworld:latest `
                --target-port 80 `
                --ingress 'external'
```

We should have these resources created.

![](images/resources.png)

Create an Azure Service Principal (SPN) to be used by Azure Pipelines to authenticate and deploy to Azure Container Apps.

```powershell
$RESOURCE_GROUP_ID=$(az group show --name $RESOURCE_GROUP --query id -o tsv)

echo $RESOURCE_GROUP_ID
# /subscriptions/xxxxxxxxxx-3960-4e6f-a663-a06fdae23428/resourceGroups/rg-containerapps-azure-pipelines

az ad sp create-for-rbac -n "spn-aca-azure-pipelines" --role Contributor --scope $RESOURCE_GROUP_ID
# {
#   "appId": "77771fc6-3cd4-4998-bc39-7c531107080c",
#   "displayName": "spn-aca-azure-pipelines",
#   "password": "udh8Q~wH9CMw4hWm5Q.qcOZQ6-Qv4hoQaXO3xbSw",
#   "tenant": "558506eb-9459-4ef3-b920-ad55c555e729"
# }
```

In Azure Pipelines, create new service connection of type `Azure Service connection` named `azure-connection` and save the SPN.

![](images/serviceconnection-azure.png)

Create another service connection to connect to Docker Hub registry.

![](images/serviceconnection-dockerhub.png)

Then create a new Azure DevOps pipeline using the following YAML. Make sure to change the variables accordingly.

```yaml
trigger:
- main

resources:
- repo: self

variables:  
  IMAGE_NAME: houssemdocker/album-backend-api
  CONTAINERAPPS_APP: album-backend-api
  CONTAINERAPPS_ENVIRONMENT: aca-environment
  RESOURCE_GROUP: rg-containerapps-azure-pipelines
  TAG: '$(Build.BuildId)'

stages:
- stage: Build
  displayName: Build and push image
  jobs:
  - job: Build
    displayName: Build
    pool:
      vmImage: ubuntu-latest
    steps:

    - task: Docker@2
      displayName: Build an image
      inputs:
        command: build
        dockerfile: '$(Build.SourcesDirectory)/backend_api/backend_api_csharp/Dockerfile'
        repository: $(IMAGE_NAME)
        tags: |
          $(TAG)

    - task: Docker@2
      displayName: Push image to Docker Hub
      inputs:
        containerRegistry: 'dockerhub-connection'
        repository: $(IMAGE_NAME)
        command: 'push'
        tags: '$(TAG)'

- stage: Deploy
  displayName: Deploy to Container Apps
  jobs:
  - job: Deploy
    displayName: Deploy
    pool:
      vmImage: ubuntu-latest
    steps:

    - task: AzureContainerApps@1
      displayName: Deploy new container version
      inputs:
        azureSubscription: 'azure-connection'
        imageToDeploy: '$(IMAGE_NAME):$(TAG)'
        containerAppName: '$(CONTAINERAPPS_APP)'
        resourceGroup: '$(RESOURCE_GROUP)'
        containerAppEnvironment: '$(CONTAINERAPPS_ENVIRONMENT)'
        targetPort: '3500'
        ingress: 'external'
```

By pushing the pipeline file, a new pipeline will start running.

![](images/pipeline-run.png)

Check the created container image.

![](images/dockerhub-image.png)

And check the deployed Container Apps using a new revision.

![](images/aca-revision.png)

ANd check the web app running.

![](images/webapp.png)

## More resources

https://learn.microsoft.com/en-us/azure/container-apps/azure-pipelines