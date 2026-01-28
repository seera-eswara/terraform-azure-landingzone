# Private DNS Zones
resource "azurerm_private_dns_zone" "main" {
  for_each = toset(var.private_dns_zones)

  name                = each.value
  resource_group_name = azurerm_resource_group.network.name

  tags = var.tags
}

# Link Private DNS Zones to Hub VNet
resource "azurerm_private_dns_zone_virtual_network_link" "hub" {
  for_each = azurerm_private_dns_zone.main

  name                  = "link-hub-${each.key}"
  resource_group_name   = azurerm_resource_group.network.name
  private_dns_zone_name = each.value.name
  virtual_network_id    = azurerm_virtual_network.hub.id
  registration_enabled  = false

  tags = var.tags
}
