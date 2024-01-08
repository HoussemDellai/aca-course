variable "prefix" {
  description = "Prefix to be used for all resources in this example"
  type        = string
  default     = "510qa"
}

variable "custom_domain_name" {
  description = "Custom domain name to be used for Application Gateway"
  type        = string
  default     = "azureappgw.com"
}

# variable "AgreedBy_IP_v6" { # "2a04:cec0:11d9:24c8:8898:3820:8631:d83"
#   type = string
# }

# variable "AgreedAt_DateTime" { # "2023-08-10T11:50:59.264Z"
#   type = string
# }

# variable "contact" {
#   type = object({
#     nameFirst = string
#     nameLast  = string
#     email     = string
#     phone     = string
#     addressMailing = object({
#       address1   = string
#       city       = string
#       state      = string
#       country    = string
#       postalCode = string
#     })
#   })
# }