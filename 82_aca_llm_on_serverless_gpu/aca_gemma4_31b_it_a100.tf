resource "azurerm_container_app" "aca_gemma4_31b_it_a100" {
  container_app_environment_id = azurerm_container_app_environment.aca_environment.id
  name                         = "gemma-4-31b-it-a100"
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"
  workload_profile_name        = "GPU-NC24-A100" # "GPU-NC8as-T4"

  ingress {
    allow_insecure_connections = true
    client_certificate_mode    = "ignore"
    external_enabled           = true
    target_port                = 8000
    transport                  = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    min_replicas                     = 0
    max_replicas                     = 1
    polling_interval_in_seconds      = 30
    cooldown_period_in_seconds       = 1800 # 300 # 3600 # 
    termination_grace_period_seconds = 30
    revision_suffix                  = ""

    container {
      image  = "vllm/vllm-openai:latest"
      # image  = "vllm/vllm-openai:gemma4-cu130"
      name   = "gemma4-31b-it"
      cpu    = 1     # 24      # 8
      memory = "8Gi" # "220Gi" # "56Gi"

      # The image entrypoint stays as-is; these are the args you passed after the image name.
      # args = [
      #   "--model", "google/gemma-4-31B-it",
      #   "--tensor-parallel-size", "1",
      #   "--max-model-len", "262144",
      #   "--gpu-memory-utilization", "0.85",
      #   "--limit-mm-per-prompt", jsonencode({ "images" : 4, "videos" : 1, "audios" : 1 }),
      #   "--speculative-config", jsonencode({ "model": "gg-hf-am/gemma-4-31B-it-assistant", "num_speculative_tokens": 4 }),
      #   "--enable-auto-tool-choice",
      #   "--tool-call-parser", "gemma4",
      #   "--reasoning-parser", "gemma4",
      #   "--chat-template", "examples/tool_chat_template_gemma4.jinja",
      #   "--host", "0.0.0.0",
      #   "--port", "8000"
      # ]

      # src: https://docs.vllm.ai/projects/recipes/en/latest/Google/Gemma4.html#pip-nvidia-cuda
      # args = [
      #   "--model", "google/gemma-4-31B-it",
      #   "--tensor-parallel-size", "1",
      #   "--max-model-len", "32768",
      #   "--gpu-memory-utilization", "0.85",
      #   "--limit-mm-per-prompt", jsonencode({ "images" : 4, "videos" : 1, "audios" : 1 }),
      #   "--enable-auto-tool-choice",
      #   "--tool-call-parser", "gemma4",
      #   "--reasoning-parser", "gemma4",
      #   "--chat-template", "examples/tool_chat_template_gemma4.jinja",
      #   "--host", "0.0.0.0",
      #   "--port", "8000"
      # ]
      args = [
        "--model", "google/gemma-4-31B-it",
        "--tensor-parallel-size", "1",
        "--max-model-len", "8000",
        "--gpu-memory-utilization", "0.85",
        "--limit-mm-per-prompt", jsonencode({ "images" : 4, "videos" : 1, "audios" : 1 }),
        "--host", "0.0.0.0",
        "--port", "8000"
      ]

      startup_probe {
        transport               = "HTTP"
        port                    = "8000"
        failure_count_threshold = "4"
        initial_delay           = "60"
        interval_seconds        = "240"
        timeout                 = "240"
      }

      liveness_probe {
        transport               = "HTTP"
        port                    = "8000"
        failure_count_threshold = "4"
        initial_delay           = "60"
        interval_seconds        = "240"
        timeout                 = "240"
      }

      readiness_probe {
        transport               = "HTTP"
        port                    = "8000"
        failure_count_threshold = "4"
        initial_delay           = "60"
        interval_seconds        = "240"
        timeout                 = "240"
      }

      # Optional: HF token if needed for gated models

      # # Optional: HF token if needed for gated models
      # env {
      #   name  = "HF_TOKEN"
      #   value = ""
      # }

      # env {
      #   name  = "VLLM_CACHE_ROOT"
      #   value = "/root/.cache/vllm" # "~/.cache/vllm"
      # }

      # env {
      #   name  = "HF_HOME"
      #   value = "/root/.cache/huggingface" # Defaults to "~/.cache/huggingface" unless XDG_CACHE_HOME is set.
      # }

      # env {
      #   name  = "HF_HUB_CACHE"
      #   value = "/root/.cache/huggingface/hub" # Defaults to "$HF_HOME/hub" (e.g. "~/.cache/huggingface/hub" by default).
      # }

      # env {
      #   name  = "HF_ASSETS_CACHE"
      #   value = "/root/.cache/huggingface/assets" # Defaults to "$HF_HOME/assets" (e.g. "~/.cache/huggingface/assets" by default).
      # }

      # env {
      #   name  = "HF_HUB_VERBOSITY"
      #   value = "warning" # {"debug", "info", "warning", "error", "critical"}, Defaults to "warning".
      # }

      # volume_mounts {
      #   name = "storage-llm"
      #   path = "/root/.cache/" # "/root/.cache/huggingface/"
      # }
    }

    # volume {
    #   name         = "storage-llm"
    #   storage_name = azurerm_container_app_environment_storage.storage_aca_llm_nfs.name # azurerm_container_app_environment_storage.storage_aca_llm.name
    #   storage_type = "NfsAzureFile"                                                     # "AzureFile" # AzureFile (SMB) or NfsAzureFile (NFS) # Volume with Nfs Azure File storage is only supported for container app on managed environment with custom VNet.
    # }

    http_scale_rule {
      name                = "http-scale"
      concurrent_requests = 2
    }
  }

  depends_on = [terraform_data.add_serverless_gpu_profile_GPU-NC24-A100]
}

output "aca_gemma4_31b_it_a100_fqdn" {
  value = azurerm_container_app.aca_gemma4_31b_it_a100.ingress.0.fqdn
}
