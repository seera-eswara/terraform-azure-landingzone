# Deploy governance policies from terraform-policy-as-code
# These policies are inherited by all child subscriptions

# Get current Azure context
data "azurerm_client_config" "current" {}

# Reference policies from terraform-policy-as-code repo
data "azurerm_policy_definition" "allowed_vm_skus" {
  name = "allowed-vm-skus"
}

data "azurerm_policy_definition" "naming_convention" {
  name = "naming-convention"
}

# Assign allowed VM SKUs policy to Platform MG
resource "azurerm_management_group_policy_assignment" "platform_allowed_skus" {
  name                 = "platform-allowed-vm-skus"
  policy_definition_id = data.azurerm_policy_definition.allowed_vm_skus.id
  management_group_id  = azurerm_management_group.platform.id

  parameters = jsonencode({
    allowedSkus = {
      value = [
        "Standard_B2ts_v2",
        "Standard_D2s_v3",
        "Standard_D4s_v3",
        "Standard_B4ms"
      ]
    }
  })

  description = "Enforce allowed VM SKUs across Platform subscriptions"
  display_name = "Platform: Allowed VM SKUs"
}

# Assign allowed VM SKUs policy to LandingZones MG
resource "azurerm_management_group_policy_assignment" "landingzone_allowed_skus" {
  name                 = "landingzone-allowed-vm-skus"
  policy_definition_id = data.azurerm_policy_definition.allowed_vm_skus.id
  management_group_id  = azurerm_management_group.landingzones.id

  parameters = jsonencode({
    allowedSkus = {
      value = [
        "Standard_B2ts_v2",
        "Standard_D2s_v3",
        "Standard_D4s_v3",
        "Standard_B4ms",
        "Standard_F2s_v2"
      ]
    }
  })

  description = "Enforce allowed VM SKUs across App Team subscriptions"
  display_name = "LandingZones: Allowed VM SKUs"
}

# Assign naming convention policy to Platform MG
resource "azurerm_management_group_policy_assignment" "platform_naming" {
  name                 = "platform-naming-convention"
  policy_definition_id = data.azurerm_policy_definition.naming_convention.id
  management_group_id  = azurerm_management_group.platform.id

  parameters = jsonencode({
    namingPattern = {
      value = "^[a-z]+-[a-z]+-[a-z]+(-[a-z0-9]+)?$"
    }
    environment = {
      value = ["dev", "stage", "prod"]
    }
  })

  description = "Enforce resource naming conventions"
  display_name = "Platform: Naming Convention"
}

# Assign naming convention policy to LandingZones MG
resource "azurerm_management_group_policy_assignment" "landingzone_naming" {
  name                 = "landingzone-naming-convention"
  policy_definition_id = data.azurerm_policy_definition.naming_convention.id
  management_group_id  = azurerm_management_group.landingzones.id

  parameters = jsonencode({
    namingPattern = {
      value = "^[a-z]+-[a-z]+-[a-z]+(-[a-z0-9]+)?$"
    }
    environment = {
      value = ["dev", "stage", "prod"]
    }
  })

  description = "Enforce resource naming conventions for app subscriptions"
  display_name = "LandingZones: Naming Convention"
}
