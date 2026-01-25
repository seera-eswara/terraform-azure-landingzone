output "cloud_mg_id" {
  description = "cloud management group ID"
  value       = module.management_groups.cloud_mg_id
}

output "landingzones_mg_id" {
  description = "Landing Zones management group ID"
  value       = module.management_groups.landingzones_mg_id
}
