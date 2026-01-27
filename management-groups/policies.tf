# Azure Policy Assignments for Management Groups
# Using policy module from terraform-policy-as-code repo
# This eliminates duplication and establishes single source of truth

module "landing_zone_policies" {
	source = "../../terraform-policy-as-code/modules/landing-zone-policies"

	# Local module expects cloudinfra_* inputs
	cloudinfra_mg_id  = azurerm_management_group.cloudinfra.id
	landingzone_mg_id = azurerm_management_group.landingzones.id

	# cloudinfra policies with stricter SKU controls
	cloudinfra_allowed_vm_skus = [
		"Standard_D4s_v3",
		"Standard_D8s_v3",
		"Standard_B4ms"
	]

	# LandingZone policies with more flexibility for app teams
	landingzone_allowed_vm_skus = [
		"Standard_B2ts_v2",
		"Standard_D2s_v3",
		"Standard_D4s_v3",
		"Standard_B4ms",
		"Standard_F2s_v2"
	]

	naming_pattern = "^[a-z]+-[a-z]+-[a-z]+(-[a-z0-9]+)?$"
	environments   = ["dev", "stage", "prod"]
}
