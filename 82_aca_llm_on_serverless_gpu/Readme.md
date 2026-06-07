# Deploying LLMs on Serverless GPU with Azure Container Apps

This project demonstrates how to deploy large language models (LLMs) on Azure Container Apps using serverless GPU capabilities. The example focuses on deploying the `Qwen-36B` model and `Gemma 4 31B` powerful LLMs, on an `NVIDIA A100` GPU.

On Azure Container Apps you can use Serverless GPU to run your containerized applications on demand, without having to manage the underlying infrastructure. The available GPU types include `NVIDIA A100`, `NVIDIA T4`. The supported GPU types are avialble with the following command.

```bash
az containerapp env workload-profile list-supported --location swedencentral -o table
Location       Name
# -------------  -------------------------
# swedencentral  D4
# swedencentral  D8
# swedencentral  D16
# swedencentral  D32
# swedencentral  E4
# swedencentral  E8
# swedencentral  E16
# swedencentral  E32
# swedencentral  Consumption
# swedencentral  Flex
# swedencentral  Consumption-GPU-NC24-A100
# swedencentral  Consumption-GPU-NC8as-T4
```
