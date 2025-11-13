resource "azurerm_firewall_policy" "firewall_policy" {
  name                = "firewall-policy"
  resource_group_name = azurerm_resource_group.rg-hub.name
  location            = var.location
  sku                 = "Standard" # "Basic" # "Premium" #
}

resource "azurerm_firewall_policy_rule_collection_group" "policy_group" {
  name               = "policy-group"
  firewall_policy_id = azurerm_firewall_policy.firewall_policy.id
  priority           = 100

  # network_rule_collection {
  #   name     = "allow-inter-spokes-traffic"
  #   priority = 102
  #   action   = "Allow"

  #   rule {
  #     name                  = "allow-inter-spokes-traffic"
  #     source_addresses      = ["10.0.0.0/8"]
  #     destination_addresses = ["10.0.0.0/8"]
  #     destination_ports     = ["*"]
  #     protocols             = ["Any"]
  #   }
  # }

  application_rule_collection {
    name     = "application-rule-allow-all"
    priority = 101
    action   = "Allow"

    rule {
      name = "allow-all"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["*"]
    }
  }

  # # allow raw.githubusercontent.com, to get the custom scripts to install to VMs
  # application_rule_collection {
  #   name     = "allow-githubusercontent-any-source"
  #   priority = 102
  #   action   = "Allow"

  #   rule {
  #     name = "allow-githubusercontent-any-source"
  #     protocols {
  #       type = "Http"
  #       port = 80
  #     }
  #     protocols {
  #       type = "Https"
  #       port = 443
  #     }
  #     source_addresses  = ["*"] # local.cidr_subnet_aks_nodes_pods # azurerm_subnet.subnet_mgt.address_prefixes
  #     destination_fqdns = ["raw.githubusercontent.com"]
  #   }
  # }

  # nat_rule_collection {
  #   name     = "dnat-inbound-rule-aks"
  #   priority = 100
  #   action   = "Dnat"

  #   rule {
  #     name                = "dnat-inbound-rule-aks"
  #     protocols           = ["TCP", "UDP"]
  #     source_addresses    = ["*"]
  #     destination_address = azurerm_public_ip.public_ip_firewall.ip_address
  #     destination_ports   = ["80"]
  #     translated_address  = "9.223.227.105"
  #     translated_port     = "80"
  #   }
  # }
}
