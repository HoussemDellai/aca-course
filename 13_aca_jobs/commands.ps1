# define environment variables

$ACA_RG="rg-aca"
$ACA_ENVIRONMENT="aca-env"
$ACA_JOB="aca-job"

# create resource group

az group create --name $ACA_RG --location westeurope

# create Container Apps Environment

az containerapp env create --name $ACA_ENVIRONMENT --resource-group $ACA_RG --location westeurope

# create and run a manual job

az containerapp job create `
    --name $ACA_JOB --resource-group $ACA_RG  --environment $ACA_ENVIRONMENT `
    --trigger-type "Manual" `
    --replica-timeout 1800 --replica-retry-limit 1 --replica-completion-count 1 --parallelism 1 `
    --image "mcr.microsoft.com/k8se/quickstart-jobs:latest" `
    --cpu "0.25" --memory "0.5Gi"

# Manual jobs don't execute automatically. You must start an execution of the job.

# Start an execution of the job

az containerapp job start --name $ACA_JOB --resource-group $ACA_RG
# {
#     "id": "/subscriptions/82f6d75e-85f4-434a-ab74-5dddd9fa8910/resourceGroups/rg-aca/providers/Microsoft.App/jobs/aca-job/executions/aca-job-p27d3de",
#     "name": "aca-job-p27d3de",
#     "resourceGroup": "rg-aca"
# }

# List recent job execution history

az containerapp job execution list `
    --name $ACA_JOB `
    --resource-group $ACA_RG `
    --output table
# Name             StartTime                  Status
# ---------------  -------------------------  ---------
# aca-job-p27d3de  2023-07-28T13:52:30+00:00  Succeeded


# Query job execution logs

# Save the Log Analytics workspace ID for the Container Apps environment to a variable.

$LOG_ANALYTICS_WORKSPACE_ID=$(az containerapp env show `
    --name $ACA_ENVIRONMENT `
    --resource-group $ACA_RG `
    --query "properties.appLogsConfiguration.logAnalyticsConfiguration.customerId" `
    --output tsv)

# Save the name of the most recent job execution to a variable.

$JOB_EXECUTION_NAME=$(az containerapp job execution list `
    --name $ACA_JOB `
    --resource-group $ACA_RG `
    --query "[0].name" `
    --output tsv)

# Run a query against Log Analytics for the job execution using the following command.

az monitor log-analytics query `
    --workspace $LOG_ANALYTICS_WORKSPACE_ID `
    --analytics-query "ContainerAppConsoleLogs_CL | where ContainerGroupName_s startswith '$JOB_EXECUTION_NAME' | order by _timestamp_d asc" `
    --query "[].Log_s"
# [
#     "2023/07/28 13:52:32 This is a sample application that demonstrates how to use Azure Container Apps jobs",
#     "2023/07/28 13:52:32 Starting processing...",
#     "2023/07/28 13:52:37 Finished processing. Shutting down!"
# ]

# Create and run a scheduled job

az containerapp job create `
    --name $ACA_JOB"-scheduled" --resource-group $ACA_RG --environment $ACA_ENVIRONMENT `
    --trigger-type "Schedule" `
    --replica-timeout 1800 --replica-retry-limit 1 --replica-completion-count 1 --parallelism 1 `
    --image "mcr.microsoft.com/k8se/quickstart-jobs:latest" `
    --cpu "0.25" --memory "0.5Gi" `
    --cron-expression "*/1 * * * *"

# Clean up resources

az group delete --name $ACA_RG --yes --no-wait