# Resource Group
resource "azurerm_resource_group" "PERSO_SIEF" {
  name     = "PERSO_SIEF"
  location = "France Central"
}

resource "azurerm_virtual_network" "skVNET" {
  name                = "skVNET"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.PERSO_SIEF.location
  resource_group_name = azurerm_resource_group.PERSO_SIEF.name
}

resource "azurerm_subnet" "skSUBNET" {
  name                 = "skSUBNET"
  resource_group_name  = azurerm_resource_group.PERSO_SIEF.name
  virtual_network_name = azurerm_virtual_network.skVNET.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "skLBPIP" {
  name                = "skLBPIP"
  location            = azurerm_resource_group.PERSO_SIEF.location
  resource_group_name = azurerm_resource_group.PERSO_SIEF.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "skLB" {
  name                = "skLB"
  location            = azurerm_resource_group.PERSO_SIEF.location
  resource_group_name = azurerm_resource_group.PERSO_SIEF.name

  frontend_ip_configuration {
    name                 = "skLBFE"
    public_ip_address_id = azurerm_public_ip.skLBPIP.id
  }
}

resource "azurerm_lb_backend_address_pool" "skLBBAP" {
  resource_group_name = azurerm_resource_group.PERSO_SIEF.name
  loadbalancer_id     = azurerm_lb.skLB.id
  name                = "skLBBAP"
}

resource "azurerm_lb_probe" "skLBPROBE" {
  resource_group_name = azurerm_resource_group.PERSO_SIEF.name
  loadbalancer_id     = azurerm_lb.skLB.id
  name                = "skLBPROBE"
  port                = 80
}

resource "azurerm_lb_rule" "skLBRULE" {
  resource_group_name            = azurerm_resource_group.PERSO_SIEF.name
  loadbalancer_id                = azurerm_lb.skLB.id
  name                           = "skLBRULE"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "skLBFE"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.skLBBAP.id
  probe_id                       = azurerm_lb_probe.skLBPROBE.id
}

module "skVM1" {
  source              = "./modules/vm"
  resource_group_name = azurerm_resource_group.PERSO_SIEF.name
  location            = azurerm_resource_group.PERSO_SIEF.location
  subnet_id           = azurerm_subnet.skSUBNET.id
  vm_name             = "skVM1"
  lb_backend_pool_id  = azurerm_lb_backend_address_pool.skLBBAP.id
}

module "skVM2" {
  source              = "./modules/vm"
  resource_group_name = azurerm_resource_group.PERSO_SIEF.name
  location            = azurerm_resource_group.PERSO_SIEF.location
  subnet_id           = azurerm_subnet.skSUBNET.id
  vm_name             = "skVM2"
  lb_backend_pool_id  = azurerm_lb_backend_address_pool.skLBBAP.id
}

resource "azurerm_mysql_server" "skMARIADB" {
  name                = "skMARIADB"
  location            = azurerm_resource_group.PERSO_SIEF.location
  resource_group_name = azurerm_resource_group.PERSO_SIEF.name

  administrator_login          = "adminuser"
  administrator_login_password = "P@ssw0rd1234"

  sku_name   = "B_Gen5_2"
  storage_mb = 5120
  version    = "5.7"

  auto_grow_enabled                 = true
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           =true
}

resource "azurerm_mysql_database" "skMARIADBDB" {
  name                = "skMARIADBDB"
  resource_group_name = azurerm_resource_group.PERSO_SIEF.name
  server_name         = azurerm_mysql_server.skMARIADB.name
  charset             = "utf8"
  collation           = "utf8_general_ci"
}

output "public_ip" {
  value = azurerm_public_ip.skLBPIP.ip_address
}