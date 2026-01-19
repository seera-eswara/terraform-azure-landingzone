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

# Platform MG assignments
resource "azurerm_role_assignment" "platform_owner" {
  for_each           = toset(var.platform_owners)
  scope              = azurerm_management_group.platform.id
  role_definition_id = data.azurerm_role_definition.owner.id
  principal_id       = each.key
}

resource "azurerm_role_assignment" "platform_contributor" {
  for_each           = toset(var.platform_contributors)
  scope              = azurerm_management_group.platform.id
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
