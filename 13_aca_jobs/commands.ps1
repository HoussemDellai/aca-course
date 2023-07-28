# 1. Create Container Apps Environment

# Define environment variables

$ACA_RG="rg-aca"
$ACA_ENVIRONMENT="aca-env"
$ACA_JOB="aca-job"

# Create resource group

az group create --name $ACA_RG --location westeurope -o table

az containerapp env create --name $ACA_ENVIRONMENT --resource-group $ACA_RG --location westeurope -o table

# 2. Create and run a manual job

az containerapp job create `
    --name $ACA_JOB --resource-group $ACA_RG  --environment $ACA_ENVIRONMENT `
    --trigger-type "Manual" `
    --replica-timeout 1800 --replica-retry-limit 1 --replica-completion-count 1 --parallelism 1 `
    --image "mcr.microsoft.com/k8se/quickstart-jobs:latest" `
    --cpu "0.25" --memory "0.5Gi" `
    -o table

# Manual jobs don't execute automatically. You must start an execution of the job.

# 3. Start an execution of the manual job

az containerapp job start --name $ACA_JOB --resource-group $ACA_RG -o table

# 4. List recent job execution history

az containerapp job execution list `
    --name $ACA_JOB `
    --resource-group $ACA_RG `
    --output table

# 5. Query job execution logs

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

# 6. Create and run a scheduled job

az containerapp job create `
    --name $ACA_JOB"-scheduled" --resource-group $ACA_RG --environment $ACA_ENVIRONMENT `
    --trigger-type "Schedule" `
    --replica-timeout 1800 --replica-retry-limit 1 --replica-completion-count 1 --parallelism 1 `
    --image "mcr.microsoft.com/k8se/quickstart-jobs:latest" `
    --cpu "0.25" --memory "0.5Gi" `
    --cron-expression "*/1 * * * *" `
    -o table

# Clean up resources

az group delete --name $ACA_RG --yes --no-wait