# variables.tfvars

# Azure provider version
azurerm_version = "~> 2.0"

# Resource Group
resource_group_name = "PERSO_SIEF"
resource_group_location = "francecentral"

# Virtual Network
virtual_network_name = "skprj01_vnet"
virtual_network_address_space = ["10.0.0.0/16"]

# Subnet
subnet_name = "skprj01_subnet"
subnet_address_prefixes = ["10.0.1.0/24"]

# Load Balancer
load_balancer_name = "skprj01_lb"

# Public IP
public_ip_name = "skprj01_pip"
public_ip_allocation_method = "Static"

# App Service Plan
app_service_plan_name = "skprj01_asp"
app_service_plan_sku_tier = "Standard"
app_service_plan_sku_size = "S1"

# Storage Account
storage_account_name = "skprj01sa"
storage_account_tier = "Standard"
storage_account_replication_type = "GRS"

# Application Insights
application_insights_name = "skprj01_ai"
application_insights_type = "web"

# Mariadb VM
mariadb_vm_os_simple = "UbuntuServer"
mariadb_vm_public_ip_dns = "skprj01_mariadb_pip"

# App Service
app_service_count = 2