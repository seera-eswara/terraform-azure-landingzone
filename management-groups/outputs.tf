output "cloudinfra_mg_id" {
  description = "Resource ID of CloudInfra management group"
  value       = azurerm_management_group.cloudinfra.id
}

output "landingzones_mg_id" {
  description = "Resource ID of LandingZones management group"
  value       = azurerm_management_group.landingzones.id
}

output "applications_mg_id" {
  description = "Resource ID of Applications management group (parent for app-specific MGs)"
  value       = azurerm_management_group.applications.id
}
