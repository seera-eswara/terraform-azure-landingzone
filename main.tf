module "management_groups" {
  source = "./management-groups"
}

# Networking module - Hub-Spoke topology with Firewall, Bastion, DDoS
module "networking" {
  source = "./networking"

  location    = var.location
  environment = var.environment

  hub_vnet_address_space = var.hub_vnet_address_space
  spoke_vnets            = var.spoke_vnets

  enable_firewall         = var.enable_firewall
  enable_bastion          = var.enable_bastion
  enable_ddos_protection  = var.enable_ddos_protection
  firewall_sku_tier       = var.firewall_sku_tier

  log_analytics_retention_days = var.log_analytics_retention_days
  private_dns_zones            = var.private_dns_zones
  app_spoke_vnets              = var.app_spoke_vnets

  tags = var.tags
}
