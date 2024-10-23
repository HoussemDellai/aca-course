# Ollama AI model deployment on Azure Container Apps

This lab will guide you through running `LLM` models on your local machine and on `Container Apps`. The lab will use the `ollama` server and client app `Open-WebUI` to deploy the models. The `ollama` server is a REST API server that can run LLM models. The client app is a web-based user interface that can interact with the `ollama` server. The `ollama` server and client app will be deployed in `Container Apps`.

## 1. Run LLM models on your local machine

The `ollama` server can run LLM models on your local machine. The `ollama` server can run LLM models like `llama3.1`, `phi3`, `gemma2`, `mistral`, `moondream`, `neural-chat`, `starling`, `codellama`, `llama2-uncensored`, `llava`, and `solar`.

### 1.1. Run `ollama` container

`ollama` server can run as a program in your machine or as a `docker` container. Here are the steps to install `ollama` server as a `docker` container. The container is available in Dockeer Hub: https://hub.docker.com/r/ollama/ollama.

```sh
docker run -d -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama
```

> For simplicity, we are running `ollama` in `CPU only` mode. Note that it can also support `GPU` and `NPU` for better performance.

### 1.2. Run Microsoft `Phi3.5` LLM model on ollama

```sh
docker exec -it ollama sh -c 'ollama run phi3.5'
# then ctrl + d to exit
```

### 1.3. Run `Open-WebUI` client app

```sh
docker run -d -p 3000:8080 --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data -e WEBUI_AUTH=False --name open-webui --restart always ghcr.io/open-webui/open-webui:main
```

Now open your browser on `http://localhost:3000` to access the `Open-WebUI` client app and you can chat with the model.

![](images/open-webui.png)

## 2. Run LLM models on Azure Container Apps

`ollama` and `Open-WebUI` are both available as Docker containers. This makes it easy to deploy it into `Container Apps`.

`ollama` and `Open-WebUI` can be deployed in AKS using Kubernetes manifests. The `ollama` server is deployed as a StatefulSet with one replica. The `Open-WebUI` client app is deployed as a Deployment with one replica. The `ollama` server and client app are deployed in the `ollama` namespace.

```sh
$RESOURCE_GROUP="rg-containerapps-ollama"
$LOCATION="swedencentral"
$ACA_ENVIRONMENT="containerapps-env-ollama"
$ACA_OLLAMA="ollama"
$ACA_OPEN_WEBUI="open-webui"

# Create an Azure Container Registry

az group create --name $RESOURCE_GROUP --location $LOCATION

# Create a Container Apps environment

az containerapp env create --name $ACA_ENVIRONMENT --resource-group $RESOURCE_GROUP --location $LOCATION

az containerapp env workload-profile add --name $ACA_ENVIRONMENT --resource-group $RESOURCE_GROUP --workload-profile-name wlp-D4 --workload-profile-type D4 --min-nodes 1 --max-nodes 2

# Deploy your backend image to a container app

az containerapp create `
  --name $ACA_OLLAMA `
  --resource-group $RESOURCE_GROUP `
  --environment $ACA_ENVIRONMENT `
  --image ollama/ollama:latest `
  --target-port 11434 `
  --ingress 'internal' `
  --workload-profile-name wlp-D4 `
  --min-replicas 1

# Communicate between container apps

$OLLAMA_BASE_URL=$(az containerapp show --resource-group $RESOURCE_GROUP --name $ACA_OLLAMA --query properties.configuration.ingress.fqdn -o tsv)

echo $OLLAMA_BASE_URL

# Deploy front end application

az containerapp create `
  --name $ACA_OPEN_WEBUI `
  --resource-group $RESOURCE_GROUP `
  --environment $ACA_ENVIRONMENT `
  --image ghcr.io/open-webui/open-webui:main `
  --target-port 8080 `
  --env-vars OLLAMA_BASE_URL=https://$OLLAMA_BASE_URL `
  --ingress 'external'
```

Now you can navigate to the public IP of the client service to chat with the model.

Here are some example models that can be used in `ollama` [available here](https://github.com/ollama/ollama/blob/main/README.md#model-library):

| Model              | Parameters | Size  | Download                       |
| ------------------ | ---------- | ----- | ------------------------------ |
| Llama 3.1          | 8B         | 4.7GB | `ollama run llama3.1`          |
| Llama 3.1          | 70B        | 40GB  | `ollama run llama3.1:70b`      |
| Llama 3.1          | 405B       | 231GB | `ollama run llama3.1:405b`     |
| Phi 3 Mini         | 3.8B       | 2.3GB | `ollama run phi3`              |
| Phi 3 Medium       | 14B        | 7.9GB | `ollama run phi3:medium`       |
| Gemma 2            | 2B         | 1.6GB | `ollama run gemma2:2b`         |
| Gemma 2            | 9B         | 5.5GB | `ollama run gemma2`            |
| Gemma 2            | 27B        | 16GB  | `ollama run gemma2:27b`        |
| Mistral            | 7B         | 4.1GB | `ollama run mistral`           |
| Moondream 2        | 1.4B       | 829MB | `ollama run moondream`         |
| Neural Chat        | 7B         | 4.1GB | `ollama run neural-chat`       |
| Starling           | 7B         | 4.1GB | `ollama run starling-lm`       |
| Code Llama         | 7B         | 3.8GB | `ollama run codellama`         |
| Llama 2 Uncensored | 7B         | 3.8GB | `ollama run llama2-uncensored` |
| LLaVA              | 7B         | 4.5GB | `ollama run llava`             |
| Solar              | 10.7B      | 6.1GB | `ollama run solar`             |

## Important notes

- The `ollama` server is running only on CPU. However, it can also run on GPU or also NPU.
- As LLM models size are large, it is recommended to use a VM with large disk space.
- During the inference, the model will consume a lot of memory and CPU. It is recommended to use a VM with a large memory and CPU.

## References

- [Ollama AI model deployment on Kubernetes](
https://github.com/open-webui/open-webui/tree/main/kubernetes/manifest/base)