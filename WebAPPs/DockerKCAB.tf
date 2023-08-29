resource "azurerm_storage_account" "sa" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "asp" {
  name                = var.app_service_plan_name
  resource_group_name      = var.resource_group_name
  location                 = var.location

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "webapp_prod" {
  name                = var.webapp_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  app_service_plan_id = azurerm_app_service_plan.asp.id

  site_config {
    linux_fx_version = "NODE|14-lts"
    always_on        = true
    min_tls_version  = "1.2"
    ftps_state       = "Disabled"
    http2_enabled    = true
    use_32_bit_worker_process = false
    websockets_enabled       = true
    remote_debugging_enabled = false
    remote_debugging_version = "VS2019"
    default_documents        = ["index.html"]
    detailed_error_logging_enabled   = true
    failed_request_tracing_enabled   = true
    http_logging_enabled             = true
    logs_directory_size_limit        = null
    request_tracing_enabled          = true
    request_tracing_expiration_time  = null
    scm_type                         ="None"
    managed_pipeline_mode            ="Integrated"
    virtual_applications             =[{
      virtual_path   ="\\"
      physical_path="%home%\\site\\wwwroot"
      preload_enabled=true}]
    
}
}

resource "azurerm_app_service" "webapp_dev" {
  name                ="${var.webapp_name}-dev"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  app_service_plan_id= azurerm_app_service_plan.asp.id

site_config{
linux_fx_version="NODE|14-lts"
always_on=true 
min_tls_version="1.2"
ftps_state="Disabled"
http2_enabled=true 
use_32_bit_worker_process=false 
websockets_enabled=true 
remote_debugging_enabled=false 
remote_debugging_version="VS2019"
default_documents=["index.html"]
detailed_error_logging_enabled=true 
failed_request_tracing_enabled=true 
http_logging_enabled=true 
logs_directory_size_limit=null 
request_tracing_enabled=true 
request_tracing_expiration_time=null 
scm_type="None"
managed_pipeline_mode="Integrated"
virtual_applications=[{
virtual_path="\\"
physical_path="%home%\\site\\wwwroot"
preload_enabled=true}]
}
}
