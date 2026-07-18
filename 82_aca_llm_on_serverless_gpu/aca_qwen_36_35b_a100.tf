resource "azurerm_container_app" "aca_qwen_36_35b_a100" {
  container_app_environment_id = azurerm_container_app_environment.aca_environment.id
  name                         = "qwen-3-6-35b-a100"
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
    cooldown_period_in_seconds       = 1800 # 300 # 3600 # 
    termination_grace_period_seconds = 30
    revision_suffix                  = ""

    container {
      image  = "vllm/vllm-openai"
      name   = "qwen36-35b-a3b"
      cpu    = 4      # 24      # 8
      memory = "64Gi" # "220Gi" # "56Gi"
      # src: https://docs.vllm.ai/projects/recipes/en/latest/Qwen/Qwen3.5.html#docker
      args = [
        "--model", "Qwen/Qwen3.6-35B-A3B",
        "--tensor-parallel-size", "1",
        "--max-model-len", "32768",
        "--gpu-memory-utilization", "0.92",
        "--enable-auto-tool-choice",
        "--tool-call-parser", "qwen3_coder",
        "--reasoning-parser", "qwen3",
        "--max-num-seqs", "200",
        "--host", "0.0.0.0",
        "--port", "8000"
        # "--enable-prefix-caching",
        # "--speculative-config", jsonencode({"method": "mtp", "num_speculative_tokens": 2}),
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
      #   value = "hf_....."
      # }
    }

    http_scale_rule {
      name                = "http-scale"
      concurrent_requests = 2
    }
  }

  depends_on = [terraform_data.add_serverless_gpu_profile_GPU-NC24-A100]
}

output "aca_qwen_36_35b_a100_fqdn" {
  value = azurerm_container_app.aca_qwen_36_35b_a100.ingress.0.fqdn
}
