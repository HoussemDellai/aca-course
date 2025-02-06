data "http" "http-request-llm" {
  url    = "${azurerm_container_app.deepseek-r1-vllm.ingress.0.fqdn}/openai/deployments/Mistral-7B-Instruct-v0.3/chat/completions?api-version=2024-10-21"
  method = "POST"

  request_headers = {
    Accept = "application/json"
    # api-key = azurerm_api_management_subscription.apim-api-subscription-openai.primary_key
  }

  request_body = <<EOF
  {
    "model": "mistralai/Mistral-7B-Instruct-v0.3",
    "prompt": "San Francisco is a",
    "max_tokens": 7,
    "temperature": 0
  }
EOF

  #   lifecycle {
  #     postcondition {
  #       condition     = contains([201, 204], self.status_code)
  #       error_message = "Status code invalid"
  #     }
  #   }
}

output "http-apim-request-response" {
  value = data.http.http-request-llm.response_body
}
