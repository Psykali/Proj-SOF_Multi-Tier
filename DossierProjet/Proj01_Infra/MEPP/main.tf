provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "PERSO_SIEF"
  location = "francecentral"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "skVNET"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "skSubnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "skNIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "skVM"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = "Standard_B1s"

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  admin_username      = "skadminadmin"
  admin_password      = "skpassadminpass"
}

resource "azurerm_mariadb_server" "mariadb" {
  name                = "skMariaDB"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  administrator_login          = "skadminadmin"
  administrator_login_password = "skpassadminpass"

  sku_name   = "B_Gen5_2"
  storage_mb = 5120
  version    = "10.3"

}

resource "azurerm_app_service_plan" "asp" {
  name                = "skASP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    tier     ="Standard"
    size     ="S1"
    capacity ="2"
}
}

resource "azurerm_app_service" "webapp1" {
   name                ="skWebApp1"
   location            ="francecentral"
   resource_group_name ="PERSO_SIEF"

   app_service_plan_id=azurerm_app_service_plan.asp.id

   site_config{
      always_on=true
      dotnet_framework_version="v4.0"
      scm_type="LocalGit"

   }
}

resource "azurerm_app_service" "webapp2" {
   name                ="skWebApp2"
   location            ="francecentral"
   resource_group_name ="PERSO_SIEF"

   app_service_plan_id=azurerm_app_service_plan.asp.id

   site_config{
      always_on=true
      dotnet_framework_version="v4.0"
      scm_type="LocalGit"

   }
}

resource "azurerm_storage_account" "storageaccount" {
   name                     ="skstorageaccount${random_string.random_string.result}"
   resource_group_name      ="PERSO_SIEF"
   location                 ="francecentral"

   account_tier             ="Standard"
   account_replication_type ="GRS"

}

resource "random_string" "random_string"{
length=8
special=false
upper=false
}


resource "azurerm_application_insights" "appinsights1"{
name="skAppInsights1"
location="francecentral"
resource_group_name="PERSO_SIEF"

application_type="web"

}


resource "azurerm_application_insights" "appinsights2"{
name="skAppInsights2"
location="francecentral"
resource_group_name="PERSO_SIEF"

application_type="web"

}

resource "azurerm_loadbalancer" "loadbalancer"{
name="skLoadBalancer"
location="francecentral"
resource_group_name="PERSO_SIEF"

frontend_ip_configuration{
name="LoadBalancerFrontEnd"
public_ip_address_id=azurerm_public_ip.publicip.id
}
}

resource "azurerm_public_ip" "publicip"{
name="skPublicIP"
location="francecentral"
resource_group_name="PERSO_SIEF"

allocation_method="Static"
sku="Standard"
}

resource "azurerm_lb_backend_address_pool" "backendpool"{
loadbalancer_id=azurerm_loadbalancer.loadbalancer.id
name="BackEndAddressPool"
}

resource "azurerm_lb_probe" "probe"{
loadbalancer_id=azurerm_loadbalancer.loadbalancer.id
name="httpProbe"
port=80
protocol="Http"
request_path="/"

}

resource "azurerm_lb_rule" "rule"{
loadbalancer_id=azurerm_loadbalancer.loadbalancer.id
name="httpRule"

protocol="Tcp"
frontend_port=80
backend_port=80

frontend_ip_configuration_name="LoadBalancerFrontEnd"
backend_address_pool_id=azurerm_lb_backend_address_pool.backendpool.id
probe_id=azurerm_lb_probe.probe.id

}

resource "azurerm_network_interface_backend_address_pool_association" "association1"{
network_interface_id=azurerm_network_interface.nic1.id
ip_configuration_name="internal"
backend_address_pool_id=azurerm_lb_backend_address_pool.backendpool.id

}

resource "azurerm_network_interface_backend_address_pool_association" "association2"{
network_interface_id=azurerm_network_interface.nic2.id
ip_configuration_name="internal"
backend_address_pool_id=azurerm_lb_backend_address_pool.backendpool.id

}