data "azurerm_client_config" "current" {}

resource "azurerm_management_group" "platform" {
  display_name = "Platform"
}

resource "azurerm_management_group" "landingzones" {
  display_name = "LandingZones"
}

resource "azurerm_management_group" "corp" {
  display_name               = "Corp"
  parent_management_group_id = azurerm_management_group.landingzones.id
}

resource "azurerm_management_group" "ai" {
  display_name               = "AI"
  parent_management_group_id = azurerm_management_group.landingzones.id
}
