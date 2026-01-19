output "platform_mg_id" {
  description = "Resource ID of Platform management group"
  value       = azurerm_management_group.platform.id
}

output "landingzones_mg_id" {
  description = "Resource ID of LandingZones management group"
  value       = azurerm_management_group.landingzones.id
}
