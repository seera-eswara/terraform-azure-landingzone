output "cloud_mg_id" {
  description = "cloud management group ID"
  value       = module.management_groups.cloud_mg_id
}

output "landingzones_mg_id" {
  description = "Landing Zones management group ID"
  value       = module.management_groups.landingzones_mg_id
}

# Networking Outputs
output "hub_vnet_id" {
  description = "Hub VNet resource ID"
  value       = module.networking.hub_vnet_id
}

output "hub_vnet_name" {
  description = "Hub VNet name"
  value       = module.networking.hub_vnet_name
}

output "spoke_vnet_ids" {
  description = "Map of spoke VNet IDs"
  value       = module.networking.spoke_vnet_ids
}

output "firewall_private_ip" {
  description = "Azure Firewall private IP address"
  value       = module.networking.firewall_private_ip
}

output "firewall_public_ip" {
  description = "Azure Firewall public IP address"
  value       = module.networking.firewall_public_ip
}

output "bastion_name" {
  description = "Azure Bastion host name"
  value       = module.networking.bastion_name
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostics"
  value       = module.networking.log_analytics_workspace_id
}

output "private_dns_zones" {
  description = "Map of private DNS zone IDs"
  value       = module.networking.private_dns_zones
}

output "network_resource_group_name" {
  description = "Network resource group name"
  value       = module.networking.network_resource_group_name
}

