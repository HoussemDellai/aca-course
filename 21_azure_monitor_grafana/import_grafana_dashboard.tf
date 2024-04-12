resource "terraform_data" "import_grafana_dashboard" {

  triggers_replace = {
    # when = timestamp()
  }

  lifecycle {
    replace_triggered_by = [azurerm_dashboard_grafana.grafana]
  }

  provisioner "local-exec" {

    when = create
    # interpreter = ["PowerShell", "-Command"]
    command = <<-EOT
        az grafana dashboard import -n ${azurerm_dashboard_grafana.grafana.name} --definition 16592
      EOT
  }
}
