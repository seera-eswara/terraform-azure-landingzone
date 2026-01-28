# App Spoke VNet Peerings
# When app teams create their spoke VNets in their subscriptions,
# the cloud team adds the peering configuration here to connect them to the hub

variable "app_spoke_vnets" {
  description = "Map of app-owned spoke VNets to peer with the hub"
  type = map(object({
    vnet_id             = string
    allow_forwarded_traffic = optional(bool, true)
    allow_gateway_transit   = optional(bool, true)
  }))
  default = {}
}

# VNet Peering: Hub to App Spokes (cross-subscription)
resource "azurerm_virtual_network_peering" "hub_to_app_spokes" {
  for_each = var.app_spoke_vnets

  name                         = "peer-hub-to-${each.key}"
  resource_group_name          = azurerm_resource_group.network.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = each.value.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = each.value.allow_forwarded_traffic
  allow_gateway_transit        = each.value.allow_gateway_transit
  use_remote_gateways          = false
}
