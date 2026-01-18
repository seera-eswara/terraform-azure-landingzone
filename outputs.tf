output "platform_mg_id" {
  description = "Platform management group ID"
  value       = module.management_groups.platform_mg_id
}

output "landingzones_mg_id" {
  description = "Landing Zones management group ID"
  value       = module.management_groups.landingzones_mg_id
}

output "corp_mg_id" {
  description = "Corp landing zone management group ID"
  value       = module.management_groups.corp_mg_id
}

output "ai_mg_id" {
  description = "AI landing zone management group ID"
  value       = module.management_groups.ai_mg_id
}
