# Cloud Infra Management Group - Reference existing MG
data "azurerm_management_group" "cloudinfra" {
  name = var.cloudinfra_mg_name
}

# Cloud Infra child MGs - Reference existing child MGs
data "azurerm_management_group" "management" {
  name = var.management_mg_name
}

data "azurerm_management_group" "connectivity" {
  name = var.connectivity_mg_name
}

data "azurerm_management_group" "identity" {
  name = var.identity_mg_name
}

# Landing Zones Management Group - Reference existing MG
data "azurerm_management_group" "landingzones" {
  name = var.landingzones_mg_name
}

# Landing Zones child MGs - Reference existing child MGs
data "azurerm_management_group" "applications" {
  name = var.applications_mg_name
}

