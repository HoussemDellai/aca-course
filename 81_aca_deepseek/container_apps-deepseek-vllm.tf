resource "azurerm_container_app" "deepseek-r1-vllm" {
  name                         = "deepseek-r1-vllm"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"
  workload_profile_name        = "profile-E16" # "Consumption"

  template {
    min_replicas = 1
    max_replicas = 1
    container {
      name    = "deepseek"
      image   = "vllm/vllm-openai:latest"
      cpu     = 15
      memory  = "120Gi"
      command = ["/bin/sh"] # ["/bin/sh", "-c"]
      args    = ["-c", "vllm serve mistralai/Mistral-7B-Instruct-v0.3 --trust-remote-code --enable-chunked-prefill --max_num_batched_tokens 1024"]
    }
  }

  ingress {
    allow_insecure_connections = true
    external_enabled           = true
    target_port                = 8000
    transport                  = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}
