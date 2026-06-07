# resource "azurerm_container_app" "aca_gemma4_31b_it_a100" {
#   container_app_environment_id = azurerm_container_app_environment.aca_environment.id
#   name                         = "gemma-4-31b-it-a100"
#   resource_group_name          = azurerm_resource_group.rg.name
#   revision_mode                = "Single"
#   workload_profile_name        = "GPU-NC24-A100" # "GPU-NC8as-T4"

#   ingress {
#     allow_insecure_connections = true
#     client_certificate_mode    = "ignore"
#     external_enabled           = true
#     target_port                = 8000
#     transport                  = "auto"

#     traffic_weight {
#       latest_revision = true
#       percentage      = 100
#     }
#   }

#   template {
#     min_replicas                     = 0
#     max_replicas                     = 1
#     polling_interval_in_seconds      = 30
#     cooldown_period_in_seconds       = 300
#     termination_grace_period_seconds = 30
#     revision_suffix                  = ""

#     container {
#       image  = "vllm/vllm-openai:gemma4-cu130"
#       name   = "gemma4-cu130"
#       cpu    = 1     # 24      # 8
#       memory = "8Gi" # "220Gi" # "56Gi"

#       # The image entrypoint stays as-is; these are the args you passed after the image name.
#       args = [
#         "--model", "google/gemma-4-31B-it",
#         "--tensor-parallel-size", "1",
#         "--max-model-len", "8736",
#         "--gpu-memory-utilization", "0.85",
#         "--limit-mm-per-prompt", jsonencode({ "images" : 4, "videos" : 1, "audios" : 1 }),
#         "--enable-auto-tool-choice",
#         "--tool-call-parser", "gemma4",
#         "--reasoning-parser", "gemma4",
#         "--chat-template", "examples/tool_chat_template_gemma4.jinja",
#         "--host", "0.0.0.0",
#         "--port", "8000"
#       ]

# #       # Optional: HF token if needed for gated models
# #       env {
# #         name  = "HF_TOKEN"
# #         value = ""
# #       }

#       # volume_mounts {
#       #   name = "storage-comfyui"
#       #   path = "/root/ComfyUI/"
#       # }
#     }

#     # volume {
#     #   name         = "storage-comfyui"
#     #   storage_name = azurerm_container_app_environment_storage.storage_aca_comfyui_nfs.name # azurerm_container_app_environment_storage.storage_aca_comfyui.name
#     #   storage_type = "NfsAzureFile" # "AzureFile" # AzureFile (SMB) or NfsAzureFile (NFS) # Volume with Nfs Azure File storage is only supported for container app on managed environment with custom VNet.
#     # }

#     http_scale_rule {
#       name                = "http-scale"
#       concurrent_requests = 2
#     }
#   }

#   depends_on = [terraform_data.add_serverless_gpu_profile_GPU-NC24-A100]
# }

# output "aca_gemma4_31b_it_a100_fqdn" {
#   value = azurerm_container_app.aca_gemma4_31b_it_a100.ingress.0.fqdn
# }
