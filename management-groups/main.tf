resource "azurerm_management_group" "platform" {
  name         = var.platform_mg_name
  display_name = "Platform"
}

resource "azurerm_management_group" "landingzones" {
  name         = var.landingzones_mg_name
  display_name = "LandingZones"
}

