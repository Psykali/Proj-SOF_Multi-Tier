provider "azurerm" {
  features {}
}

# Create the virtual network and subnets
resource "azurerm_virtual_network" "skvnet" {
  name                = "skvnet"
  address_space       = ["10.0.0.0/16"]
  location            = "francecentral"
  resource_group_name = "PERSO_SIEF"

  subnet {
    name           = "sksubnet"
    address_prefix = "10.0.1.0/24"
  }
}

# Create the local network gateway
resource "azurerm_local_network_gateway" "sklng" {
  name                = "sklng"
  resource_group_name = "PERSO_SIEF"
  location            = "francecentral"
  gateway_ip_address  = "203.0.113.1"
  address_space       = ["192.168.1.0/24"]
}

# Create the VPN gateway connection
resource "azurerm_virtual_network_gateway_connection" "skvgc" {
  name                          = "skvgc"
  location                      = "francecentral"
  resource_group_name           = "PERSO_SIEF"
  virtual_network_gateway_id    = azurerm_virtual_network_gateway.skvng.id
  local_network_gateway_id      = azurerm_local_network_gateway.sklng.id
  connection_type               = "IPsec"
  routing_weight                = 1
  shared_key                    = "MySharedKey123"
  enable_bgp                    = false
  use_policy_based_traffic_selectors = false

  ipsec_policy {
    sa_life_time_seconds = 3600
    ipsec_encryption     = "AES256"
    ipsec_integrity      = "SHA256"
    dh_group             = "DHGroup2"
    pfs_group            = "PFS2"
  }

  tags = {
    Environment = "Production"
  }
}

# Create the VPN gateway
resource "azurerm_virtual_network_gateway" "skvng" {
  name                = "skvng"
  location            = "francecentral"
  resource_group_name = "PERSO_SIEF"
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = "VpnGw1"
  active_active       = false

  ip_configuration {
    name                          = "skipconfig"
    subnet_id                     = azurerm_subnet.sksubnet.id
    public_ip_address_id          = azurerm_public_ip.skvpn.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create the public IP address for the VPN gateway
resource "azurerm_public_ip" "skvpn" {
  name                = "skvpnpublicip"
  location            = "francecentral"
  resource_group_name = "PERSO_SIEF"
  allocation_method   = "Dynamic"
  sku                 = "Standard"
}

# Create the ADF
resource "azurerm_data_factory" "skadf" {
  name                = "skadf"
  location            = "francecentral"
  resource_group_name = "PERSO_SIEF"
}

# Create the ADF linked service for the VPN gateway
resource "azurerm_data_factory_linked_service_azure_virtual_network" "skadf_link" {
  name                = "skadf_link"
  data_factory_name   = azurerm_data_factory.skadf.name
  resource_group_name = "PERSO_SIEF"
  virtual_network_id  = azurerm_virtual_network.skvnet.id
  subnet_name         = azurerm_subnet.sksubnet.name
  gateway_name        = azurerm_virtual_network_gateway_connection.skvgc.name
}

# Create the subnet
resource "azurerm_subnet" "sksubnet" {
  name                 = "sksubnet"
  resource_group_name  = "PERSO_SIEF"
  virtual_network_name = azurerm_virtual_network.skvnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create the network security group and rules
resource "azurerm_network_security_group" "sknsg" {
  name                = "sknsg"
  location            = "francecentral"
  resource_group_name = "PERSO_SIEF"

  security_rule {
    name                       = "skallow-rdp"
    priority                   = 100
    direction                  = "Inbound"
    access= "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "skallow-ssh"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create the network interface for the ADF
resource "azurerm_network_interface" "skadf_nic" {
  name                = "skadf_nic"
  location            = "francecentral"
  resource_group_name = "PERSO_SIEF"

  ip_configuration {
    name                          = "skadf_ipconfig"
    subnet_id                     = azurerm_subnet.sksubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.skvpn.id
  }

  depends_on = [
    azurerm_network_security_group.sknsg,
    azurerm_data_factory_linked_service_azure_virtual_network.skadf_link,
  ]
}

# Assign the network interface to the ADF
resource "azurerm_data_factory_network_interface" "skadf_ni" {
  name                = "skadf_ni"
  data_factory_name   = azurerm_data_factory.skadf.name
  resource_group_name = "PERSO_SIEF"
  network_interface_id = azurerm_network_interface.skadf_nic.id
}

# Create the storage account for the ADF
resource "azurerm_storage_account" "skadf_sa" {
  name                     = "skadfstorage"
  resource_group_name      = "PERSO_SIEF"
  location                 = "francecentral"
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

# Create the linked service for the storage account
resource "azurerm_data_factory_linked_service_azure_storage" "skadf_sa_link" {
  name                = "skadf_sa_link"
  data_factory_name   = azurerm_data_factory.skadf.name
  resource_group_name = "PERSO_SIEF"
  connection_string   = azurerm_storage_account.skadf_sa.primary_connection_string
}

# Create the dataset for the storage account
resource "azurerm_data_factory_azure_blob_dataset" "skadf_ds" {
  name                = "skadf_ds"
  data_factory_name   = azurerm_data_factory.skadf.name
  resource_group_name = "PERSO_SIEF"
  linked_service_name = azurerm_data_factory_linked_service_azure_storage.skadf_sa_link.name
  folder_path         = "myfolder"
  file_name           = "myfile.txt"
}

# Create the pipeline for the ADF
resource "azurerm_data_factory_pipeline" "skadf_pipeline" {
  name                = "skadf_pipeline"
  data_factory_name   = azurerm_data_factory.skadf.name
  resource_group_name = "PERSO_SIEF"

  activity {
    name                 = "skadf_copyactivity"
    type                 = "Copy"
    linked_service_name  = azurerm_data_factory_linked_service_azure_storage.skadf_sa_link.name
    inputs               = []
    outputs              = []
    translation {
      type = "TabularTranslator"
      column_mappings {
        source {
          name = "Column1"
        }
        sink {
          name = "Column1"
        }
      }
    }
    copy {
      source {
        type            = "BlobSource"
        recursive       = false
        folder_path     = "myfolder"
        file_path       = "myfile.txt"
        partition_option {
          name        = "None"
        }
      }
      sink {
        type            = "BlobSink"
        write_batch_size = 0
        write_behavior  = "AppendRow"
        copy_behavior   = "PreserveHierarchy"
        blob_path       = "output/myfile.txt"
        blob_name       = "myfile.txt"
        partition_option {
          name        = "None"
        }
      }
      enable_staging = false
      allow_polybase = false
      preserve_nulls = false
      validation {
        minimum_rows_per_partition = 0
        validation_mode            = "Skip"
      }
      data_integrity {
        retry_interval_in_seconds = 0
        retry_times                = 3
        validation_strategy        = "None"
      }
    }
  }
}