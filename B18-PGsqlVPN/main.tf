terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.40.0"
    }
  }
}
# Define the Azure provider
provider "azurerm" {
  features {}
}

## Create a resource group
#resource "azurerm_resource_group" "example" {
#  name     = "example-resource-group"
#  location = "West Europe"
#}

# Create a virtual network
resource "azurerm_virtual_network" "example" {
  name                = "example-virtual-network"
  address_space       = ["10.1.0.0/16"]
  location = "West Europe"
##  location            = azurerm_resource_group.example.location
  resource_group_name = "PERSO_SIEF"
##  resource_group_name = azurerm_resource_group.example.name
}

# Create a subnet for the database
resource "azurerm_subnet" "database" {
  name                 = "database-subnet"
  resource_group_name = "PERSO_SIEF"
##  resource_group_name = azurerm_resource_group.example.name
  address_prefixes     = ["10.1.1.0/24"]
  virtual_network_name = azurerm_virtual_network.example.name
}

# Create a subnet for the VPN gateway
resource "azurerm_subnet" "gateway" {
  name                 = "gateway-subnet"
  resource_group_name = "PERSO_SIEF"
##  resource_group_name = azurerm_resource_group.example.name
  address_prefixes     = ["10.1.2.0/24"]
  virtual_network_name = azurerm_virtual_network.example.name
}

# Create a public IP address for the VPN gateway
resource "azurerm_public_ip" "vpn_gateway" {
  name                = "vpn-gateway-ip"
  location = "West Europe"
##  location            = azurerm_resource_group.example.location
  resource_group_name = "PERSO_SIEF"
##  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
}

# Create the VPN gateway
resource "azurerm_virtual_network_gateway" "vpn_gateway" {
  name                = "vpn-gateway"
  location = "West Europe"
##  location            = azurerm_resource_group.example.location
  resource_group_name = "PERSO_SIEF"
##  resource_group_name = azurerm_resource_group.example.name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  active_active       = false
  enable_bgp          = false
  sku                 = "VpnGw1"
  ip_configuration {
    name                          = "vpn-gateway-ip-config"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway.id
  }
}

# Create a Postgres SQL server
resource "azurerm_postgresql_server" "example" {
  name                = "example-psqlserver"
  location = "West Europe"
##  location            = azurerm_resource_group.example.location
  resource_group_name = "PERSO_SIEF"
##  resource_group_name = azurerm_resource_group.example.name

  administrator_login          = "psqladmin"
  administrator_login_password = "H@Sh1CoR3!"

  sku_name   = "GP_Gen5_4"
  version    = "11"
  storage_mb = 640000

  backup_retention_days        = 7
  geo_redundant_backup_enabled = true
  auto_grow_enabled            = true

  public_network_access_enabled    = false
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
}


# Create a firewall rule to block all external access to the database
resource "azurerm_postgresql_firewall_rule" "block_all" {
  name                = "block-all"
  server_name         = azurerm_postgresql_server.example.name
  resource_group_name = "PERSO_SIEF"
##  resource_group_name = azurerm_resource_group.example.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

# Create a firewall rule to allow access to the database from the VPN subnet
resource "azurerm_postgresql_firewall_rule" "allow_vpn_subnet" {
  name                = "allow-vpn-subnet"
  server_name         = azurerm_postgresql_server.example.name
  resource_group_name = azurerm_resource_group.example.name
  start_ip_address    = "10.1.1.1"
  end_ip_address      = "10.1.1.100"
}

# Output the VPN gateway's public IP address
output "vpn_gateway_public_ip" {
  value = azurerm_public_ip.vpn_gateway.ip_address
}