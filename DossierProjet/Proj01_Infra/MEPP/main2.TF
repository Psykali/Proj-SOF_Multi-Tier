resource "azurerm_resource_group" "sk_rg" {
  name     = "PERSO_SIEF"
  location = "francecentral"
}

resource "azurerm_virtual_network" "sk_vnet" {
  name                = "sk-vnet"
  resource_group_name = azurerm_resource_group.sk_rg.name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.sk_rg.location
}

resource "azurerm_subnet" "sk_subnet" {
  name                 = "sk-subnet"
  resource_group_name  = azurerm_resource_group.sk_rg.name
  virtual_network_name = azurerm_virtual_network.sk_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_storage_account" "sk_storage" {
  name                     = "skstorageaccount"
  resource_group_name      = azurerm_resource_group.sk_rg.name
  location                 = azurerm_resource_group.sk_rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_container" "sk_images_container" {
  name                  = "sk-images-container"
  resource_group_name   = azurerm_resource_group.sk_rg.name
  storage_account_name  = azurerm_storage_account.sk_storage.name
  container_access_type = "private"
}

resource "azurerm_sql_server" "sk_sql_server" {
  name                         = "sksqlserver"
  resource_group_name          = azurerm_resource_group.sk_rg.name
  location                     = azurerm_resource_group.sk_rg.location
  version                      = "12.0"
  administrator_login          = "database_admin"
  administrator_login_password = "P@ssw0rd"
}

resource "azurerm_sql_database" "sk_sql_db" {
  name                = "sksqldb"
  resource_group_name = azurerm_resource_group.sk_rg.name
  location            = azurerm_resource_group.sk_rg.location
  server_name         = azurerm_sql_server.sk_sql_server.name
  sku_name            = "BC_Gen5_2"
  collation_name      = "SQL_Latin1_General_CP1_CI_AS"
  edition             = "Standard"

  connection_policy {
    connection_mode = "Default"
    authentication  = "SqlLogin"
    username        = "database_user"
    password        = "P@ssw0rd"
    parameterized_query_enabled = true
  }
}

resource "azurerm_virtual_machine" "sk_vm" {
  name                  = "sk-vm"
  resource_group_name   = azurerm_resource_group.sk_rg.name
  location              = azurerm_resource_group.sk_rg.location
  availability_set_id   = azurerm_availability_set.sk_availability_set.id
  network_interface_ids = [azurerm_network_interface.sk_nic.id]
  vm_size               = "Standard_D2_v3"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_os_disk {
    name              = "sk-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "sk-vm"
    admin_username = "adminuser"
    admin_password = "P@ssw0rd"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y curl apt-transport-https gnupg2",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce",
      "sudo usermod -aG docker $USER",
      "sudo docker run -d --restart=always -p 1433:1433 -e ACCEPT_EULA=Y -e SA_PASSWORD=P@ssw0rd -e MSSQL_PID=Developer mcr.microsoft.com/mssql/server:2019-latest"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -",
      "sudo apt-add-repository \"$(wget -qO- https://packages.microsoft.com/config/ubuntu/18.04/mssql-server-2019.list)\"",
      "sudo apt-get update",
      "sudo apt-get install -y mssql-tools unixodbc-dev",
      "echo 'export PATH=\"$PATH:/opt/mssql-tools/bin\"' >> ~/.bashrc",
      "source ~/.bashrc",
      "sudo apt-get install -y python3-pip",
      "pip3 install pymssql"
    ]
  }
}

resource "azurerm_network_interface" "sk_nic" {
  name                      = "sk-nic"
  resource_group_name       = azurerm_resource_group.sk_rg.name
  location                  = azurerm_resource_group.sk_rg.location
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "sk-ipconfig"
    subnet_id                     = azurerm_subnet.sk_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_availability_set" "sk_availability_set" {
  name                = "sk-availset"
  resource_group_name = azurerm_resource_group.sk_rg.name
  location            = azurerm_resource_group.sk_rg.location
}

resource "azurerm_kubernetes_cluster" "sk_kubernetes_cluster" {
  name                = "sk-k8s"
  location            = azurerm_resource_group.sk_rg.location
  resource_group_name = azurerm_resource_group.sk_rg.name
  dns_prefix          = "sk-k8s-dns"
  linux_profile {
    admin_username = "azureuser"
    ssh_key {
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }
  agent_pool_profile {
    name            = "sk-agentpool"
    count           = 1
    vm_size         = "Standard_D2_v3"
    os_type         = "Linux"
    vnet_subnet_id  = azurerm_subnet.sk_subnet.id
  }
  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }
  depends_on = [
    azurerm_subnet.sk_subnet,
    azurerm_kubernetes_service_version.sk_kubernetes_version,
  ]
}

resource "azurerm_kubernetes_service_version" "sk_kubernetes_version" {
  depends_on = [azurerm_resource_group.sk_rg]
  location   = azurerm_resource_group.sk_rg.location
  request_timeout_seconds = 86400
  maintenance_window {
    day_of_week    = "Sunday"
    start_time_utc = "02:00"
    duration_hours = 5
  }
}

output "sk_cluster_kube_config" {
  value = azurerm_kubernetes_cluster.sk_kubernetes_cluster.kube_config_raw
}

output "sk_cluster_id" {
  value = azurerm_kubernetes_cluster.sk_kubernetes_cluster.id
}

output "sk_cluster_name" {
  value = azurerm_kubernetes_cluster.sk_kubernetes_cluster.name
}

output "sk_cluster_location" {
  value = azurerm_kubernetes_cluster.sk_kubernetes_cluster.location
}