output "hub_vnet_id" {
  description = "Hub VNet resource ID"
  value       = azurerm_virtual_network.hub.id
}

output "hub_vnet_name" {
  description = "Hub VNet name"
  value       = azurerm_virtual_network.hub.name
}

output "spoke_vnet_ids" {
  description = "Map of spoke VNet IDs"
  value       = { for k, v in azurerm_virtual_network.spoke : k => v.id }
}

output "spoke_vnet_names" {
  description = "Map of spoke VNet names"
  value       = { for k, v in azurerm_virtual_network.spoke : k => v.name }
}

output "firewall_private_ip" {
  description = "Azure Firewall private IP address"
  value       = var.enable_firewall ? azurerm_firewall.main[0].ip_configuration[0].private_ip_address : null
}

output "firewall_public_ip" {
  description = "Azure Firewall public IP address"
  value       = var.enable_firewall ? azurerm_public_ip.firewall[0].ip_address : null
}

output "bastion_name" {
  description = "Azure Bastion host name"
  value       = var.enable_bastion ? azurerm_bastion_host.main[0].name : null
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostics"
  value       = azurerm_log_analytics_workspace.network.id
}

output "log_analytics_workspace_name" {
  description = "Log Analytics workspace name"
  value       = azurerm_log_analytics_workspace.network.name
}

output "private_dns_zones" {
  description = "Map of private DNS zone IDs"
  value       = { for k, v in azurerm_private_dns_zone.main : k => v.id }
}

output "ddos_protection_plan_id" {
  description = "DDoS Protection Plan ID"
  value       = var.enable_ddos_protection ? azurerm_network_ddos_protection_plan.main[0].id : null
}

output "network_resource_group_name" {
  description = "Network resource group name"
  value       = azurerm_resource_group.network.name
}

output "spoke_subnets" {
  description = "Map of spoke subnet IDs"
  value       = { for k, v in azurerm_subnet.spoke : k => v.id }
}

output "spoke_route_tables" {
  description = "Map of spoke route table IDs"
  value       = { for k, v in azurerm_route_table.spoke : k => v.id }
}

output "spoke_nsgs" {
  description = "Map of spoke NSG IDs"
  value       = { for k, v in azurerm_network_security_group.spoke : k => v.id }
}
