# Cloud Infra Management Group - for Cloud Infra Team resources
resource "azurerm_management_group" "cloudinfra" {
  name         = var.cloudinfra_mg_name
  display_name = "CloudInfra"
}

# Cloud Infra child MGs
resource "azurerm_management_group" "management" {
  name                       = var.management_mg_name
  display_name               = "Management"
  parent_management_group_id = azurerm_management_group.cloudinfra.id
}

resource "azurerm_management_group" "connectivity" {
  name                       = var.connectivity_mg_name
  display_name               = "Connectivity"
  parent_management_group_id = azurerm_management_group.cloudinfra.id
}

resource "azurerm_management_group" "identity" {
  name                       = var.identity_mg_name
  display_name               = "Identity"
  parent_management_group_id = azurerm_management_group.cloudinfra.id
}

resource "azurerm_management_group" "landingzones" {
  name         = var.landingzones_mg_name
  display_name = "LandingZones"
}

# Landing Zones child MGs
resource "azurerm_management_group" "applications" {
  name                       = var.applications_mg_name
  display_name               = "Applications"
  parent_management_group_id = azurerm_management_group.landingzones.id
}

