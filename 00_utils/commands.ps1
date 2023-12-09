# list the supported workload profiles for Azure Container Apps
(az account list-locations --query "[?metadata.regionType=='Physical'].name" -o tsv)

# list the supported workload profiles for Azure Container Apps for all regions
ForEach($l in $(az account list-locations --query "[?metadata.regionType=='Physical'].name" -o tsv))
{
    echo "Listing VMs for $l ..."
    az containerapp env workload-profile list-supported -l $l --query "[].{Name: name, Cores: properties.cores, MemoryGiB: properties.memoryGiB, Category: properties.category}" -o table
}