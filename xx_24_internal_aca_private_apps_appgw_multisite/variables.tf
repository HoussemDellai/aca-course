variable "prefix" {
  type = string
  default = "24"
}

variable "location" {
  type = string
  default = "swedencentral"
}

variable "custom_domain_name" {
  type = string
  default = "apps.internal"
}

variable "apps" {
  default = ["01", "02", "03"]
}