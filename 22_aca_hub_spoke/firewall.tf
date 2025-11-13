# Subnet for Azure Firewall, without NSG as per Firewall requirements
resource "azurerm_subnet" "subnet_firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_virtual_network.vnet-hub.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet-hub.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "public_ip_firewall" {
  name                = "public-ip-firewall"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-hub.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
}

resource "azurerm_firewall" "firewall" {
  name                = "firewall-hub"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-hub.name
  sku_name            = "AZFW_VNet"           # AZFW_Hub
  sku_tier            = "Standard"  # Premium  # "Basic" # 
  firewall_policy_id  = azurerm_firewall_policy.firewall_policy.id
  zones               = ["1"] # ["1", "2", "3"]
  # dns_servers         = ["168.63.129.16"]
  # threat_intel_mode = "Alert" # Off, Alert,Deny and ""(empty string). Defaults to Alert.

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.subnet_firewall.id
    public_ip_address_id = azurerm_public_ip.public_ip_firewall.id
  }
}