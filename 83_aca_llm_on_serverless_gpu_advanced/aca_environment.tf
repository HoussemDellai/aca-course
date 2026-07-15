resource "azurerm_container_app_environment" "aca_environment" {
  name                           = "aca-env-gpu-llm"
  location                       = azurerm_resource_group.rg.location
  resource_group_name            = azurerm_resource_group.rg.name
  public_network_access          = "Enabled"
  logs_destination               = "azure-monitor" # "log-analytics"
  internal_load_balancer_enabled = false
  zone_redundancy_enabled        = false
  infrastructure_subnet_id       = azurerm_subnet.snet_aca.id

  identity {
    type = "SystemAssigned"
  }

  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }

  workload_profile {
    name                  = "profile-D4"
    workload_profile_type = "D4" # D4, D8, D16, D32, E4, E8, E16 and E32.
    minimum_count         = 0
    maximum_count         = 1
  }

  # workload_profile {
  #   name                  = "GPU-NC8as-T4"
  #   workload_profile_type = "Consumption-GPU-NC8as-T4" # D4, D8, D16, D32, E4, E8, E16 and E32.
  #   # minimum_count         = 0
  #   # maximum_count         = 1
  # }

  # workload_profile {
  #   name                  = "GPU-NC24-A100"
  #   workload_profile_type = "Consumption-GPU-NC24-A100" # D4, D8, D16, D32, E4, E8, E16 and E32.
  #   # minimum_count         = 0
  #   # maximum_count         = 1
  # }

  lifecycle {
    ignore_changes = [workload_profile]
  }
}

# There is a bug with adding GPU profiles via terraform, so we need to use local-exec to run the az cli command to add the GPU profiles after the ACA environment is created
resource "terraform_data" "add_serverless_gpu_profile_GPU-NC8as-T4" {
  triggers_replace = [azurerm_container_app_environment.aca_environment.id]

  provisioner "local-exec" {
    command = "az containerapp env workload-profile add --name ${azurerm_container_app_environment.aca_environment.name} --resource-group ${azurerm_container_app_environment.aca_environment.resource_group_name} --workload-profile-type Consumption-GPU-NC8as-T4 --workload-profile-name GPU-NC8as-T4"
  }

  depends_on = [ azurerm_container_app_environment.aca_environment ]
}

# There is a bug with adding GPU profiles via terraform, so we need to use local-exec to run the az cli command to add the GPU profiles after the ACA environment is created
resource "terraform_data" "add_serverless_gpu_profile_GPU-NC24-A100" {
  triggers_replace = [azurerm_container_app_environment.aca_environment.id]

  provisioner "local-exec" {
    command = "az containerapp env workload-profile add --name ${azurerm_container_app_environment.aca_environment.name} --resource-group ${azurerm_container_app_environment.aca_environment.resource_group_name} --workload-profile-type Consumption-GPU-NC24-A100 --workload-profile-name GPU-NC24-A100"
  }

  depends_on = [ azurerm_container_app_environment.aca_environment, terraform_data.add_serverless_gpu_profile_GPU-NC8as-T4 ]
}

output "supported_workload_profiles" {
  value = "az containerapp env workload-profile list-supported --location ${azurerm_resource_group.rg.location} -o table"
}