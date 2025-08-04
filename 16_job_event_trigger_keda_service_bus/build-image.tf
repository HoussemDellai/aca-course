# resource "terraform_data" "build_container_image" {
#   count            = 1
#   triggers_replace = [var.image_tag] # triggers build image when tag changes

#   lifecycle {
#     replace_triggered_by = [azurerm_container_registry.acr]
#   }

#   provisioner "local-exec" {
#     when    = create
#     command = <<-EOT
#         az acr build -r ${azurerm_container_registry.acr.name} -f ./app/Dockerfile ./app/ -t job-python:${var.image_tag} --no-format
#       EOT
#   }
# }
