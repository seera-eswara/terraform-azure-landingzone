output "cloudinfra_mg_id" {
  description = "Resource ID of CloudInfra management group"
  value       = azurerm_management_group.cloudinfra.id
}

output "landingzones_mg_id" {
  description = "Resource ID of LandingZones management group"
  value       = azurerm_management_group.landingzones.id
}
