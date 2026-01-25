resource "azurerm_management_group" "cloud" {
  name         = var.cloud_mg_name
  display_name = "cloud"
}

resource "azurerm_management_group" "landingzones" {
  name         = var.landingzones_mg_name
  display_name = "LandingZones"
}

