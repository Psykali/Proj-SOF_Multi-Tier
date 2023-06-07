# Define provider
provider "azurerm" {
  features {}
}

# Define variables
variable "resource_group_name" {
  description = "Name of the resource group"
  default     = "PERSO_SIEF"
}

variable "location" {
  description = "Azure region"
  default     = "France Central"
}

variable "lgw_name" {
  description = "Name of the local gateway"
  default     = "LGW-PersoSK"
}

variable "lgw_ip" {
  description = "IP address of the local gateway"
  default     = "10.0.0.1"
}

variable "local_address_prefix" {
  description = "Address prefix of the local network"
  default     = "192.168.0.0/24"
}

variable "rgw_name" {
  description = "Name of the remote VPN gateway"
  default     = "RGW-PersoSK"
}

variable "rgw_ip" {
  description = "IP address of the remote VPN gateway"
  default     = "1.2.3.4"
}

variable "remote_address_prefix" {
  description = "Address prefix of the remote network"
  default     = "10.0.0.0/16"
}

variable "connection_name" {
  description = "Name of the VPN connection"
  default     = "VPN-Connection-PersoSK"
}

# Create local network gateway
resource "azurerm_local_network_gateway" "lgw_example" {
  name                = var.lgw_name
  resource_group_name = var.resource_group_name
  location            = var.location
  gateway_ip_address  = var.lgw_ip
  address_space       = [var.local_address_prefix]
}

# Create VPN gateway
resource "azurerm_virtual_network" "vnet_example" {
  name                = "VNET-PersoSK"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]

  subnet {
    name           = "GatewaySubnet"
    address_prefix = "10.0.0.0/24"
  }
}

resource "azurerm_virtual_network_gateway" "rgw_example" {
  name                = var.rgw_name
  resource_group_name = var.resource_group_name
  location            = var.location
  ip_configuration {
    name                          = "GatewayConfig"
    subnet_id                     = azurerm_virtual_network.vnet_example.subnet_gateway.id
    private_ip_address_allocation = "Dynamic"
  }
  gateway_type    = "Vpn"
  vpn_type        = "RouteBased"
  sku             = "VpnGw1"
  enable_bgp      = false
  vpn_gateway_generation = "Generation1"
}

# Create VPN connection
resource "azurerm_virtual_network_gateway_connection" "conn_example" {
  name                      = var.connection_name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  virtual_network_gateway1  = azurerm_virtual_network_gateway.rgw_example.id
  local_network_gateway2_id = azurerm_local_network_gateway.lgw_example.id
  connection_type           = "IPsec"
  shared_key                = "YourSharedKey"
  routing_weight            = 10
}

# Output VPN client address pool
output "vpn_client_address_pool" {
  value = azurerm_virtual_network_gateway.rgw_example.vpn_client_configuration.0.vpn_client_address_pool.0.address_prefixes
}
