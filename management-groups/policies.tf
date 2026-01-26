# Azure Policy Assignments for Management Groups
# Using policy module from terraform-policy-as-code repo
# This eliminates duplication and establishes single source of truth

# Temporarily disabled - pending policy module variable alignment
# module "landing_zone_policies" {
#   source = "git::https://github.com/seera-eswara/terraform-policy-as-code.git//modules/landing-zone-policies?ref=v1.1.0"
#
#   cloud_mg_id    = azurerm_management_group.cloudinfra.id
#   landingzone_mg_id = azurerm_management_group.landingzones.id
#
#   # cloud policies with stricter SKU controls
#   cloud_allowed_vm_skus = [
#     "Standard_D4s_v3",
#     "Standard_D8s_v3",
#     "Standard_B4ms"
#   ]
#
#   # LandingZone policies with more flexibility for app teams
#   landingzone_allowed_vm_skus = [
#     "Standard_B2ts_v2",
#     "Standard_D2s_v3",
#     "Standard_D4s_v3",
#     "Standard_B4ms",
#     "Standard_F2s_v2"
#   ]
#
#   naming_pattern = "^[a-z]+-[a-z]+-[a-z]+(-[a-z0-9]+)?$"
#   environments   = ["dev", "stage", "prod"]
# }
