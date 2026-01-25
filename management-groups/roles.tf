# IAM role assignments at management group scope

# Built-in role definitions
# Owner and Contributor retrieved at tenant scope

data "azurerm_role_definition" "owner" {
  name  = "Owner"
  scope = "/"
}

data "azurerm_role_definition" "contributor" {
  name  = "Contributor"
  scope = "/"
}

# cloud MG assignments
resource "azurerm_role_assignment" "cloud_owner" {
  for_each           = toset(var.cloud_owners)
  scope              = azurerm_management_group.cloud.id
  role_definition_id = data.azurerm_role_definition.owner.id
  principal_id       = each.key
}

resource "azurerm_role_assignment" "cloud_contributor" {
  for_each           = toset(var.cloud_contributors)
  scope              = azurerm_management_group.cloud.id
  role_definition_id = data.azurerm_role_definition.contributor.id
  principal_id       = each.key
}

# LandingZones MG assignments
resource "azurerm_role_assignment" "landingzones_owner" {
  for_each           = toset(var.landingzones_owners)
  scope              = azurerm_management_group.landingzones.id
  role_definition_id = data.azurerm_role_definition.owner.id
  principal_id       = each.key
}

resource "azurerm_role_assignment" "landingzones_contributor" {
  for_each           = toset(var.landingzones_contributors)
  scope              = azurerm_management_group.landingzones.id
  role_definition_id = data.azurerm_role_definition.contributor.id
  principal_id       = each.key
}
