resource "azurerm_container_app_job" "aca_job_download_models" {
  name                         = "aca-job-download-models"
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  container_app_environment_id = azurerm_container_app_environment.aca_environment.id
  workload_profile_name        = "Consumption"
  replica_timeout_in_seconds   = 1800 # 30 minutes
  replica_retry_limit          = 10

  manual_trigger_config {
    parallelism              = 1
    replica_completion_count = 1
  }

  template {
    container {
      name    = "download-models"
      image   = "python:3.14.4" # "ubuntu:24.04"
      cpu     = 1
      memory  = "2Gi"
      command = ["/bin/bash"]
      args    = ["-c", "pip install -U huggingface_hub && hf download google/gemma-4-31B-it"]
      # args    = ["-c", "pip install -U huggingface_hub && hf download HuggingFaceH4/zephyr-7b-beta"]
      # args    = ["-c", "pip install -U huggingface_hub && hf download HuggingFaceH4/zephyr-7b-beta --cache-dir /root/.cache/"]
      # args    = ["-c", "apt-get update && apt-get install -y wget && wget https://raw.githubusercontent.com/HoussemDellai/ai-course/refs/heads/main/555_comfyui_on_aca/download-models-comfyui.sh && chmod +x /download-models-comfyui.sh && /download-models-comfyui.sh"]


      env {
        name  = "VLLM_CACHE_ROOT"
        value = "/root/.cache/vllm" # "~/.cache/vllm"
      }

      env {
        name  = "HF_HOME"
        value = "/root/.cache/huggingface" # Defaults to "~/.cache/huggingface" unless XDG_CACHE_HOME is set.
      }

      env {
        name  = "HF_HUB_CACHE"
        value = "/root/.cache/huggingface/hub" # Defaults to "$HF_HOME/hub" (e.g. "~/.cache/huggingface/hub" by default).
      }

      env {
        name  = "HF_ASSETS_CACHE"
        value = "/root/.cache/huggingface/assets" # Defaults to "$HF_HOME/assets" (e.g. "~/.cache/huggingface/assets" by default).
      }

      env {
        name  = "HF_HUB_VERBOSITY"
        value = "warning" # {"debug", "info", "warning", "error", "critical"}, Defaults to "warning".
      }

      volume_mounts {
        name = "storage-llm"
        path = "/root/.cache/"
      }
    }

    volume {
      name         = "storage-llm"
      storage_name = azurerm_container_app_environment_storage.storage_aca_llm_nfs.name
      storage_type = "NfsAzureFile" # "EmptyDir"
    }
  }
}

# trigger the job to start downloading models to the storage
resource "azapi_resource_action" "start_job" {
  type        = "Microsoft.App/jobs@2025-07-01"
  resource_id = azurerm_container_app_job.aca_job_download_models.id
  action      = "start"
  method      = "POST"
}
