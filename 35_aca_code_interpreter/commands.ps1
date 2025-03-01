# src: https://learn.microsoft.com/en-us/azure/container-apps/sessions-tutorial-langchain

$rgName = "aca-code-interpreter"
$location = "swedencentral"
$sessionName  = "my-session-pool"
$azureOpenaiName = "az-openai-0013-demo"

# Create a resource group
az group create --name $rgName --location $location

az containerapp sessionpool create `
    --name $sessionName `
    --resource-group $rgName `
    --location $location `
    --container-type PythonLTS `
    --max-sessions 100 `
    --cooldown-period 300 `
    --network-status EgressDisabled

az containerapp sessionpool show `
    --name $sessionName `
    --resource-group $rgName `
    --query 'properties.poolManagementEndpoint' -o tsv

az cognitiveservices account create `
    --name $azureOpenaiName `
    --resource-group $rgName `
    --location $location `
    --kind OpenAI `
    --sku s0 `
    --custom-domain $azureOpenaiName

az cognitiveservices account deployment create `
    --resource-group $rgName `
    --name $azureOpenaiName `
    --deployment-name gpt-4o `
    --model-name gpt-4o `
    --model-version "2024-08-06" `
    --model-format OpenAI `
    --sku-capacity "100" `
    --sku-name "GlobalStandard"

git clone https://github.com/Azure-Samples/container-apps-dynamic-sessions-samples.git

cd container-apps-dynamic-sessions-samples/langchain-python-webapi

# Create a Python virtual environment and activate it:
python3 -m venv .venv

# If you're using Windows, replace .venv/bin/activate with .venv\Scripts\activate.
source .venv/bin/activate

python -m pip install -r requirements.txt

az cognitiveservices account show `
    --name $azureOpenaiName `
    --resource-group $rgName `
    --query properties.endpoint `
    --output tsv

az containerapp sessionpool show `
    --name $sessionName `
    --resource-group $rgName `
    --query properties.poolManagementEndpoint `
    --output tsv

# create the .env file


$userName=(az account show --query user.name --output tsv)

$azureOpenaiId=(az cognitiveservices account show --name $azureOpenaiName --resource-group $rgName --query id --output tsv)

az role assignment create --role "Cognitive Services OpenAI User" --assignee $userName --scope $azureOpenaiId

$sessionId=(az containerapp sessionpool show --name $sessionName --resource-group $rgName --query id --output tsv)

az role assignment create `
    --role "Azure ContainerApps Session Executor" `
    --assignee $userName `
    --scope $sessionId

# install fastapi
pip install fastapi

fastapi dev main.py

# Optional: Deploy the sample app to Azure Container Apps