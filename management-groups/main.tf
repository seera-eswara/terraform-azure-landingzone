data "azurerm_client_config" "current" {}


data "azurerm_management_group" "root" {
  name = data.azurerm_client_config.current.tenant_id
}

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
