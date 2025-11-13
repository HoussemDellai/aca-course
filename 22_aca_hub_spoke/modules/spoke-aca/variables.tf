variable "prefix" {
  type = string
  default = "22"
}

variable "location" {
  type = string
  default = "swedencentral"
}

variable "cidr_vnet" {
  default = ["10.1.0.0/16"]
}

variable "cidr_snet_aca" {
  default = ["10.1.0.0/24"]
}

variable "cidr_snet_vm" {
  default = ["10.1.1.0/24"]
}

variable "vnet_hub" {
  type = object({
    name                = string
    resource_group_name = string
    id                  = string
  })
}

variable "private_dns_zone" {
  type = object({
    name                = string
    resource_group_name = string
  })
}

variable "custom_domain_name" {
  type = string
  default = "internal.corp"
}