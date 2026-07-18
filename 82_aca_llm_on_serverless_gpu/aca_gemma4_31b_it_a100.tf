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
    min_replicas                     = 1
    max_replicas                     = 1
    polling_interval_in_seconds      = 30
    cooldown_period_in_seconds       = 1800
    termination_grace_period_seconds = 30
    revision_suffix                  = ""

    container {
      image  = "vllm/vllm-openai:gemma4-cu130"
      name   = "gemma4-31b-it"
      cpu    = 4      # 24      # 8
      memory = "32Gi" # "16Gi" # "220Gi" # "56Gi"

      # src: https://docs.vllm.ai/projects/recipes/en/latest/Google/Gemma4.html#pip-nvidia-cuda
      args = [
        "--model", "google/gemma-4-31B-it",
        "--tensor-parallel-size", "1",
        "--max-model-len", "32768",
        "--gpu-memory-utilization", "0.85",
        "--limit-mm-per-prompt", jsonencode({ "images" : 4, "videos" : 1, "audios" : 1 }),
        "--enable-auto-tool-choice",
        "--tool-call-parser", "gemma4",
        "--reasoning-parser", "gemma4",
        "--chat-template", "examples/tool_chat_template_gemma4.jinja",
        "--host", "0.0.0.0",
        "--port", "8000"
      ]

      startup_probe {
        path                    = "/health"
        transport               = "HTTP"
        port                    = "8000"
        failure_count_threshold = "4"
        initial_delay           = "60"
        interval_seconds        = "240"
        timeout                 = "240"
      }

      liveness_probe {
        path                    = "/health"
        transport               = "HTTP"
        port                    = "8000"
        failure_count_threshold = "4"
        initial_delay           = "60"
        interval_seconds        = "240"
        timeout                 = "240"
      }

      readiness_probe {
        path                    = "/health"
        transport               = "HTTP"
        port                    = "8000"
        failure_count_threshold = "4"
        initial_delay           = "60"
        interval_seconds        = "240"
        timeout                 = "240"
      }

      # # Optional: HF token if needed for gated models
      # env {
      #   name  = "HF_TOKEN"
      #   value = ""
      # }
    }

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
