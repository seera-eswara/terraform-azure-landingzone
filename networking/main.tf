# Resource Group for Networking
resource "azurerm_resource_group" "network" {
  name     = "rg-network-hub-${var.environment}"
  location = var.location
  tags     = var.tags
}

# Log Analytics Workspace for diagnostics
resource "azurerm_log_analytics_workspace" "network" {
  name                = "law-network-${var.environment}"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_analytics_retention_days

  tags = var.tags
}

# DDoS Protection Plan
resource "azurerm_network_ddos_protection_plan" "main" {
  count = var.enable_ddos_protection ? 1 : 0

  name                = "ddos-protection-plan-${var.environment}"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name

  tags = var.tags
}

# Hub Virtual Network
resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-${var.environment}"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  address_space       = var.hub_vnet_address_space

  dynamic "ddos_protection_plan" {
    for_each = var.enable_ddos_protection ? [1] : []
    content {
      id     = azurerm_network_ddos_protection_plan.main[0].id
      enable = true
    }
  }

  tags = var.tags
}

# Hub VNet Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "hub_vnet" {
  name                       = "diag-vnet-hub"
  target_resource_id         = azurerm_virtual_network.hub.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.network.id

  enabled_log {
    category = "VMProtectionAlerts"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Azure Firewall Subnet (must be named AzureFirewallSubnet)
resource "azurerm_subnet" "firewall" {
  count = var.enable_firewall ? 1 : 0

  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Azure Bastion Subnet (must be named AzureBastionSubnet)
resource "azurerm_subnet" "bastion" {
  count = var.enable_bastion ? 1 : 0

  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Gateway Subnet for VPN/ExpressRoute
resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.3.0/24"]
}

# Management Subnet for jumpboxes, management VMs
resource "azurerm_subnet" "management" {
  name                 = "snet-management"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.4.0/24"]
}

# Public IP for Azure Firewall
resource "azurerm_public_ip" "firewall" {
  count = var.enable_firewall ? 1 : 0

  name                = "pip-firewall-${var.environment}"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]

  tags = var.tags
}

# Firewall Public IP Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "firewall_pip" {
  count = var.enable_firewall ? 1 : 0

  name                       = "diag-pip-firewall"
  target_resource_id         = azurerm_public_ip.firewall[0].id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.network.id

  enabled_log {
    category = "DDoSProtectionNotifications"
  }

  enabled_log {
    category = "DDoSMitigationFlowLogs"
  }

  enabled_log {
    category = "DDoSMitigationReports"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Azure Firewall Policy
resource "azurerm_firewall_policy" "main" {
  count = var.enable_firewall ? 1 : 0

  name                     = "afwp-${var.environment}"
  resource_group_name      = azurerm_resource_group.network.name
  location                 = azurerm_resource_group.network.location
  sku                      = var.firewall_sku_tier
  threat_intelligence_mode = "Alert"

  dns {
    proxy_enabled = true
  }

  intrusion_detection {
    mode = "Alert"
  }

  tags = var.tags
}

# Firewall Policy Rule Collection Group - Network Rules
resource "azurerm_firewall_policy_rule_collection_group" "network_rules" {
  count = var.enable_firewall ? 1 : 0

  name               = "DefaultNetworkRuleCollectionGroup"
  firewall_policy_id = azurerm_firewall_policy.main[0].id
  priority           = 100

  network_rule_collection {
    name     = "AllowAzureServices"
    priority = 100
    action   = "Allow"

    rule {
      name                  = "AllowAzureMonitor"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["AzureMonitor"]
      destination_ports     = ["443"]
    }

    rule {
      name                  = "AllowAzureStorage"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["Storage"]
      destination_ports     = ["443"]
    }

    rule {
      name                  = "AllowAzureKeyVault"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["AzureKeyVault"]
      destination_ports     = ["443"]
    }
  }

  network_rule_collection {
    name     = "AllowDNS"
    priority = 200
    action   = "Allow"

    rule {
      name                  = "AllowDNSOutbound"
      protocols             = ["UDP"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["53"]
    }
  }
}

# Firewall Policy Rule Collection Group - Application Rules
resource "azurerm_firewall_policy_rule_collection_group" "application_rules" {
  count = var.enable_firewall ? 1 : 0

  name               = "DefaultApplicationRuleCollectionGroup"
  firewall_policy_id = azurerm_firewall_policy.main[0].id
  priority           = 200

  application_rule_collection {
    name     = "AllowWindowsUpdates"
    priority = 100
    action   = "Allow"

    rule {
      name = "AllowMicrosoftUpdates"
      source_addresses = ["*"]
      destination_fqdns = [
        "*.windowsupdate.microsoft.com",
        "*.update.microsoft.com",
        "*.windowsupdate.com"
      ]
      protocols {
        type = "Https"
        port = 443
      }
    }
  }

  application_rule_collection {
    name     = "AllowAzureServices"
    priority = 200
    action   = "Allow"

    rule {
      name = "AllowAzureManagement"
      source_addresses = ["*"]
      destination_fqdns = [
        "*.azure.com",
        "*.microsoft.com",
        "*.microsoftonline.com"
      ]
      protocols {
        type = "Https"
        port = 443
      }
    }
  }
}

# Azure Firewall
resource "azurerm_firewall" "main" {
  count = var.enable_firewall ? 1 : 0

  name                = "afw-hub-${var.environment}"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  sku_name            = "AZFW_VNet"
  sku_tier            = var.firewall_sku_tier
  firewall_policy_id  = azurerm_firewall_policy.main[0].id
  zones               = ["1", "2", "3"]

  ip_configuration {
    name                 = "fw-ipconfig"
    subnet_id            = azurerm_subnet.firewall[0].id
    public_ip_address_id = azurerm_public_ip.firewall[0].id
  }

  tags = var.tags
}

# Firewall Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "firewall" {
  count = var.enable_firewall ? 1 : 0

  name                       = "diag-firewall"
  target_resource_id         = azurerm_firewall.main[0].id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.network.id

  enabled_log {
    category = "AzureFirewallApplicationRule"
  }

  enabled_log {
    category = "AzureFirewallNetworkRule"
  }

  enabled_log {
    category = "AzureFirewallDnsProxy"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Public IP for Azure Bastion
resource "azurerm_public_ip" "bastion" {
  count = var.enable_bastion ? 1 : 0

  name                = "pip-bastion-${var.environment}"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

# Azure Bastion Host
resource "azurerm_bastion_host" "main" {
  count = var.enable_bastion ? 1 : 0

  name                = "bastion-hub-${var.environment}"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  sku                 = "Standard"
  copy_paste_enabled  = true
  file_copy_enabled   = true
  tunneling_enabled   = true

  ip_configuration {
    name                 = "bastion-ipconfig"
    subnet_id            = azurerm_subnet.bastion[0].id
    public_ip_address_id = azurerm_public_ip.bastion[0].id
  }

  tags = var.tags
}

# Bastion Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "bastion" {
  count = var.enable_bastion ? 1 : 0

  name                       = "diag-bastion"
  target_resource_id         = azurerm_bastion_host.main[0].id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.network.id

  enabled_log {
    category = "BastionAuditLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
