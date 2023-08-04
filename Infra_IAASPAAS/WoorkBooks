resource "azurerm_application_insights_workbook" "example" {
  name                = "example-workbook"
  location            = var.location
  resource_group_name = var.resource_group_name
  display_name        = "Example Workbook"

  data_json = file("./workbook.json")
}
