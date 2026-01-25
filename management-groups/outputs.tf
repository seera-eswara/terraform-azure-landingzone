output "cloud_mg_id" {
  description = "Resource ID of cloud management group"
  value       = azurerm_management_group.cloud.id
}

output "landingzones_mg_id" {
  description = "Resource ID of LandingZones management group"
  value       = azurerm_management_group.landingzones.id
}
