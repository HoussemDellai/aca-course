variable "prefix" {
  type    = string
  default = "18"
}

variable "custom_domain_name" {
  type    = string
  default = "aca-app.com"
  validation {
    condition     = length(var.custom_domain_name) > 0 && (endswith(var.custom_domain_name, ".com") || endswith(var.custom_domain_name, ".net") || endswith(var.custom_domain_name, ".co.uk") || endswith(var.custom_domain_name, ".org") || endswith(var.custom_domain_name, ".nl") || endswith(var.custom_domain_name, ".in") || endswith(var.custom_domain_name, ".biz") || endswith(var.custom_domain_name, ".org.uk") || endswith(var.custom_domain_name, ".co.in"))
    error_message = "Available top level domains are: com, net, co.uk, org, nl, in, biz, org.uk, and co.in"
  }
}

variable "AgreedBy_IP_v6" { # "2a04:cec0:11d9:24c8:8898:3820:8631:d83"
  type    = string
  default = "2a04:cec0:11d9:24c8:8898:3820:8631:d83"
}

variable "AgreedAt_DateTime" { # "2023-08-10T11:50:59.264Z"
  type    = string
  default = "2023-08-10T11:50:59.264Z"
}

variable "contact" {
  type = object({
    nameFirst = string
    nameLast  = string
    email     = string
    phone     = string
    addressMailing = object({
      address1   = string
      city       = string
      state      = string
      country    = string
      postalCode = string
    })
  })

  default = {
    nameFirst = "Houssem"
    nameLast  = "Dellai"
    email     = "houssem.dellai@live.com" # you'll get verification email
    phone     = "+33.762954328"
    addressMailing = {
      address1   = "1 Microsoft Way"
      city       = "Redmond"
      state      = "WA"
      country    = "US"
      postalCode = "98052"
    }
  }
}
