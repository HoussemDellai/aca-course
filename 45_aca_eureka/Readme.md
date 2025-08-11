Source: https://learn.microsoft.com/en-us/azure/container-apps/java-eureka-server?tabs=azure-cli


Create the Eureka Server for Spring Java component

```sh
az containerapp env java-component eureka-server-for-spring create --environment aca-environment -g rg-containerapp-eureka-45 --name eureka
# {
#   "id": "/subscriptions/dcef7009-6b94-4382-afdc-17eb160d709a/resourceGroups/rg-containerapp-eureka-45/providers/Microsoft.App/managedEnvironments/aca-environment/javaComponents/eureka",
#   "name": "eureka",
#   "properties": {
#     "componentType": "SpringCloudEureka",
#     "configurations": null,
#     "ingress": {
#       "fqdn": "eureka-azure-java.ext.orangewater-13f4fcf1.swedencentral.azurecontainerapps.io"
#     },
#     "provisioningState": "Succeeded",
#     "scale": {
#       "maxReplicas": 1,
#       "minReplicas": 1
#     },
#     "serviceBinds": null
#   },
#   "resourceGroup": "rg-containerapp-eureka-45",
#   "systemData": {
#     "createdAt": "2025-08-11T13:47:05.168085",
#     "createdBy": "admin@MngEnvMCAP784683.onmicrosoft.com",
#     "createdByType": "User",
#     "lastModifiedAt": "2025-08-11T13:47:05.168085",
#     "lastModifiedBy": "admin@MngEnvMCAP784683.onmicrosoft.com",
#     "lastModifiedByType": "User"
#   },
#   "type": "Microsoft.App/managedEnvironments/javaComponents"
# }
```

Optional: Update the Eureka Server for Spring Java component configuration.

```sh
az containerapp env java-component eureka-server-for-spring update --environment aca-environment -g rg-containerapp-eureka-45 --name eureka --configuration eureka.server.renewal-percent-threshold=0.85 eureka.server.eviction-interval-timer-in-ms=10000
# {
#   "id": "/subscriptions/dcef7009-6b94-4382-afdc-17eb160d709a/resourceGroups/rg-containerapp-eureka-45/providers/Microsoft.App/managedEnvironments/aca-environment/javaComponents/eureka",
#   "name": "eureka",
#   "properties": {
#     "componentType": "SpringCloudEureka",
#     "configurations": [
#       {
#         "propertyName": "eureka.server.renewal-percent-threshold",
#         "value": "0.85"
#       },
#       {
#         "propertyName": "eureka.server.eviction-interval-timer-in-ms",
#         "value": "10000"
#       }
#     ],
#     "ingress": {
#       "fqdn": "eureka-azure-java.ext.orangewater-13f4fcf1.swedencentral.azurecontainerapps.io"
#     },
#     "provisioningState": "Succeeded",
#     "scale": {
#       "maxReplicas": 1,
#       "minReplicas": 1
#     },
#     "serviceBinds": null
#   },
#   "resourceGroup": "rg-containerapp-eureka-45",
#   "systemData": {
#     "createdAt": "2025-08-11T13:47:05.168085",
#     "createdBy": "admin@MngEnvMCAP784683.onmicrosoft.com",
#     "createdByType": "User",
#     "lastModifiedAt": "2025-08-11T13:49:51.6374433",
#     "lastModifiedBy": "admin@MngEnvMCAP784683.onmicrosoft.com",
#     "lastModifiedByType": "User"
#   },
#   "type": "Microsoft.App/managedEnvironments/javaComponents"
# }
```

Bind your container app to the Eureka Server for Spring Java component

```sh
az containerapp update --resource-group rg-containerapp-eureka-45 --name aca-app-java-spring --bind eureka
az containerapp update --resource-group rg-containerapp-eureka-45 --name aca-app-eureka-client --bind eureka
# {
#   "id": "/subscriptions/dcef7009-6b94-4382-afdc-17eb160d709a/resourceGroups/rg-containerapp-eureka-45/providers/Microsoft.App/containerapps/aca-app-java-spring",
#   "identity": {
#     "type": "None"
#   },
#   "location": "Sweden Central",
#   "name": "aca-app-java-spring",
#   "properties": {
#     "configuration": {
#       "activeRevisionsMode": "Single",
#       "dapr": null,
#       "identitySettings": [],
#       "ingress": {
#         "additionalPortMappings": null,
#         "allowInsecure": false,
#         "clientCertificateMode": null,
#         "corsPolicy": null,
#         "customDomains": null,
#         "exposedPort": 0,
#         "external": true,
#         "fqdn": "aca-app-java-spring.orangewater-13f4fcf1.swedencentral.azurecontainerapps.io",
#         "ipSecurityRestrictions": null,
#         "stickySessions": null,
#         "targetPort": 80,
#         "targetPortHttpScheme": null,
#         "traffic": [
#           {
#             "latestRevision": true,
#             "weight": 100
#           }
#         ],
#         "transport": "Auto"
#       },
#       "maxInactiveRevisions": 0,
#       "registries": null,
#       "revisionTransitionThreshold": null,
#       "runtime": null,
#       "secrets": null,
#       "service": null,
#       "targetLabel": ""
#     },
#     "customDomainVerificationId": "12A824F56ADC4DBFA2BAB33D11CF904692CB9810204E47093CF78548458D595C",
#     "delegatedIdentities": [],
#     "environmentId": "/subscriptions/dcef7009-6b94-4382-afdc-17eb160d709a/resourceGroups/rg-containerapp-eureka-45/providers/Microsoft.App/managedEnvironments/aca-environment",    
#     "eventStreamEndpoint": "https://swedencentral.azurecontainerapps.dev/subscriptions/dcef7009-6b94-4382-afdc-17eb160d709a/resourceGroups/rg-containerapp-eureka-45/containerApps/aca-app-java-spring/eventstream",
#     "latestReadyRevisionName": "aca-app-java-spring--0jv8pph",
#     "latestRevisionFqdn": "aca-app-java-spring--0000001.orangewater-13f4fcf1.swedencentral.azurecontainerapps.io",
#     "latestRevisionName": "aca-app-java-spring--0000001",
#     "managedEnvironmentId": "/subscriptions/dcef7009-6b94-4382-afdc-17eb160d709a/resourceGroups/rg-containerapp-eureka-45/providers/Microsoft.App/managedEnvironments/aca-environment",
#     "outboundIpAddresses": [
#       "20.240.28.167",
#       "20.240.28.184",
#       "9.223.20.105",
#       "135.116.6.186",
#       "9.223.21.30",
#       "9.223.218.210",
#       "135.116.14.134",
#       "9.223.143.243",
#       "9.223.9.149",
#       "74.241.137.85",
#       "74.241.139.161",
#       "74.241.138.64",
#       "20.240.28.187",
#       "74.241.136.237",
#       "9.223.21.119",
#       "9.223.10.153",
#       "9.223.225.145",
#       "9.223.220.233",
#       "74.241.136.44",
#       "9.223.87.134",
#       "74.241.139.29",
#       "9.223.20.250",
#       "9.223.20.145",
#       "20.240.29.51",
#       "74.241.193.90",
#       "74.241.192.157",
#       "74.241.192.45",
#       "74.241.193.154",
#       "74.241.192.111",
#       "74.241.193.34",
#       "20.240.38.142",
#       "20.240.38.235",
#       "9.223.237.26",
#       "9.223.246.165",
#       "74.241.209.91",
#       "74.241.211.241",
#       "9.223.245.238",
#       "135.116.14.86",
#       "9.223.173.128",
#       "9.223.237.22",
#       "4.225.86.27",
#       "9.223.75.69",
#       "20.240.37.255",
#       "9.223.245.208",
#       "9.223.237.31",
#       "9.223.45.114",
#       "9.223.24.231",
#       "74.241.210.170",
#       "9.223.246.185",
#       "9.223.16.144",
#       "135.116.37.178",
#       "9.223.247.36",
#       "9.223.18.163",
#       "20.240.37.231",
#       "74.241.204.139",
#       "74.241.204.246",
#       "74.241.202.17",
#       "74.241.200.59",
#       "74.241.205.78",
#       "74.241.203.192",
#       "9.223.251.248",
#       "135.116.5.56"
#     ],
#     "patchingMode": "Automatic",
#     "provisioningState": "Succeeded",
#     "runningStatus": "Running",
#     "template": {
#       "containers": [
#         {
#           "image": "ghcr.io/azure-samples/javaaccelerator/spring-petclinic-api-gateway",
#           "imageType": "ContainerImage",
#           "name": "aca-app",
#           "probes": [],
#           "resources": {
#             "cpu": 0.25,
#             "ephemeralStorage": "1Gi",
#             "memory": "0.5Gi"
#           }
#         }
#       ],
#       "initContainers": null,
#       "revisionSuffix": "",
#       "scale": {
#         "cooldownPeriod": 300,
#         "maxReplicas": 10,
#         "minReplicas": null,
#         "pollingInterval": 30,
#         "rules": null
#       },
#       "serviceBinds": [
#         {
#           "clientType": "none",
#           "name": "eureka",
#           "serviceId": "/subscriptions/dcef7009-6b94-4382-afdc-17eb160d709a/resourceGroups/rg-containerapp-eureka-45/providers/Microsoft.App/managedEnvironments/aca-environment/javaComponents/eureka"
#         }
#       ],
#       "terminationGracePeriodSeconds": null,
#       "volumes": []
#     },
#     "workloadProfileName": "Consumption"
#   },
#   "resourceGroup": "rg-containerapp-eureka-45",
#   "systemData": {
#     "createdAt": "2025-08-11T13:38:53.3832697",
#     "createdBy": "admin@MngEnvMCAP784683.onmicrosoft.com",
#     "createdByType": "User",
#     "lastModifiedAt": "2025-08-11T14:02:12.1776141",
#     "lastModifiedBy": "admin@MngEnvMCAP784683.onmicrosoft.com",
#     "lastModifiedByType": "User"
#   },
#   "tags": {},
#   "type": "Microsoft.App/containerApps"
# }
# az containerapp update --resource-group rg-containerapp-eureka-45 --name aca-app-java-spring --bind configserver eureka admin

# az containerapp create --name $APP_NAME --resource-group $RESOURCE_GROUP --environment $ENVIRONMENT --image $IMAGE --min-replicas 1 --max-replicas 1 --ingress external --target-port 8080 --bind $EUREKA_COMPONENT_NAME --query properties.configuration.ingress.fqdn
```

```sh
az containerapp env java-component eureka-server-for-spring show --resource-group rg-containerapp-eureka-45 --name eureka --environment aca-environment --query properties.ingress.fqdn
```
