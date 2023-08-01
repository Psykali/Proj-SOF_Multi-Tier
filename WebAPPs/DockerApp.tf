#resource "azurerm_app_service" "webapp_docker" {
#  name                = "psykprojwbdckr"
#  location            = "France Central"
#  resource_group_name = "PERSO_SIEF"
#  app_service_plan_id = azurerm_app_service_plan.example.id

#  site_config {
#    always_on = true

    # Set the container settings for the Docker image deployment
#    linux_fx_version = "DOCKER|climatemind/webapp:production"
#  }

#  identity {
#    type = "SystemAssigned"
#  }

#  tags = {
#    environment = "Production"
#  }
#}

resource "azurerm_app_service" "sof20" {
  name                = "psykprojsofdck"
  location            = "France Central"
  resource_group_name = "PERSO_SIEF"
  app_service_plan_id = azurerm_app_service_plan.example.id

  site_config {
    always_on = true

    # Set the container settings for the Docker image deployment
    linux_fx_version = "DOCKER|siscc/dotstatsuite-webapp-template:latest"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_app_service" "wikijs" {
  name                = "psykprojwikidck"
  location            = "France Central"
  resource_group_name = "PERSO_SIEF"
  app_service_plan_id = azurerm_app_service_plan.example.id

  site_config {
    always_on = true

    # Set the container settings for the Docker image deployment
    linux_fx_version = "DOCKER|stackstorm/st2chatops:latest"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "Production"
  }
}