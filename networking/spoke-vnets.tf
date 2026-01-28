# Spoke Virtual Networks
resource "azurerm_virtual_network" "spoke" {
  for_each = var.spoke_vnets

  name                = "vnet-${each.key}-${var.environment}"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  address_space       = each.value.address_space

  dynamic "ddos_protection_plan" {
    for_each = var.enable_ddos_protection ? [1] : []
    content {
      id     = azurerm_network_ddos_protection_plan.main[0].id
      enable = true
    }
  }

  tags = var.tags
}

# Spoke VNet Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "spoke_vnet" {
  for_each = azurerm_virtual_network.spoke

  name                       = "diag-${each.key}"
  target_resource_id         = each.value.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.network.id

  enabled_log {
    category = "VMProtectionAlerts"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Spoke Subnets
resource "azurerm_subnet" "spoke" {
  for_each = merge([
    for vnet_key, vnet in var.spoke_vnets : {
      for subnet_key, subnet in vnet.subnets :
      "${vnet_key}-${subnet_key}" => merge(subnet, {
        vnet_key    = vnet_key
        subnet_key  = subnet_key
      })
    }
  ]...)

  name                 = each.value.subnet_key
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.spoke[each.value.vnet_key].name
  address_prefixes     = [each.value.address_prefix]
  service_endpoints    = lookup(each.value, "service_endpoints", [])

  dynamic "delegation" {
    for_each = lookup(each.value, "delegation", null) != null ? [each.value.delegation] : []
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}

# VNet Peering: Hub to Spoke
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  for_each = azurerm_virtual_network.spoke

  name                         = "peer-hub-to-${each.key}"
  resource_group_name          = azurerm_resource_group.network.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = each.value.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}

# VNet Peering: Spoke to Hub
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  for_each = azurerm_virtual_network.spoke

  name                         = "peer-${each.key}-to-hub"
  resource_group_name          = azurerm_resource_group.network.name
  virtual_network_name         = each.value.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# Link Private DNS Zones to Spoke VNets
resource "azurerm_private_dns_zone_virtual_network_link" "spoke" {
  for_each = merge([
    for vnet_key, vnet in azurerm_virtual_network.spoke : {
      for dns_zone in var.private_dns_zones :
      "${vnet_key}-${replace(dns_zone, ".", "-")}" => {
        vnet_key = vnet_key
        vnet_id  = vnet.id
        dns_zone = dns_zone
      }
    }
  ]...)

  name                  = "link-${each.value.vnet_key}-${replace(each.value.dns_zone, ".", "-")}"
  resource_group_name   = azurerm_resource_group.network.name
  private_dns_zone_name = each.value.dns_zone
  virtual_network_id    = each.value.vnet_id
  registration_enabled  = false

  tags = var.tags

  depends_on = [azurerm_private_dns_zone.main]
}

# Route Table for Spoke Subnets
resource "azurerm_route_table" "spoke" {
  for_each = var.spoke_vnets

  name                          = "rt-${each.key}-${var.environment}"
  location                      = azurerm_resource_group.network.location
  resource_group_name           = azurerm_resource_group.network.name
  disable_bgp_route_propagation = false

  tags = var.tags
}

# Default Route to Firewall
resource "azurerm_route" "default_to_firewall" {
  for_each = var.enable_firewall ? var.spoke_vnets : {}

  name                   = "route-default-to-firewall"
  resource_group_name    = azurerm_resource_group.network.name
  route_table_name       = azurerm_route_table.spoke[each.key].name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.enable_firewall ? azurerm_firewall.main[0].ip_configuration[0].private_ip_address : null
}

# Associate Route Tables with Spoke Subnets
resource "azurerm_subnet_route_table_association" "spoke" {
  for_each = azurerm_subnet.spoke

  subnet_id      = each.value.id
  route_table_id = azurerm_route_table.spoke[split("-", each.key)[0]].id
}

# Network Security Group for Spoke Subnets
resource "azurerm_network_security_group" "spoke" {
  for_each = var.spoke_vnets

  name                = "nsg-${each.key}-${var.environment}"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name

  tags = var.tags
}

# Default NSG Rules
resource "azurerm_network_security_rule" "deny_all_inbound" {
  for_each = azurerm_network_security_group.spoke

  name                        = "DenyAllInbound"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = each.value.name
}

resource "azurerm_network_security_rule" "allow_vnet_inbound" {
  for_each = azurerm_network_security_group.spoke

  name                        = "AllowVNetInbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = each.value.name
}

resource "azurerm_network_security_rule" "allow_azure_loadbalancer" {
  for_each = azurerm_network_security_group.spoke

  name                        = "AllowAzureLoadBalancerInbound"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = each.value.name
}

# Associate NSG with Spoke Subnets
resource "azurerm_subnet_network_security_group_association" "spoke" {
  for_each = azurerm_subnet.spoke

  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.spoke[split("-", each.key)[0]].id
}

# NSG Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "nsg" {
  for_each = azurerm_network_security_group.spoke

  name                       = "diag-${each.key}"
  target_resource_id         = each.value.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.network.id

  enabled_log {
    category = "NetworkSecurityGroupEvent"
  }

  enabled_log {
    category = "NetworkSecurityGroupRuleCounter"
  }
}
