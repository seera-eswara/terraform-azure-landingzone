variable "hub_vnet_address_space" {
  description = "Address space for the hub VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "spoke_vnets" {
  description = "Map of spoke VNets to create"
  type = map(object({
    address_space = list(string)
    subnets = map(object({
      address_prefix = string
      service_endpoints = optional(list(string), [])
      delegation = optional(object({
        name = string
        service_delegation = object({
          name    = string
          actions = list(string)
        })
      }))
    }))
  }))
  default = {
    "spoke-app" = {
      address_space = ["10.1.0.0/16"]
      subnets = {
        "app-subnet" = {
          address_prefix = "10.1.1.0/24"
          service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
        }
        "data-subnet" = {
          address_prefix = "10.1.2.0/24"
          service_endpoints = ["Microsoft.Sql", "Microsoft.Storage"]
        }
      }
    }
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "enable_ddos_protection" {
  description = "Enable DDoS protection plan (~$2,944/month - DISABLE for learning)"
  type        = bool
  default     = false  # Changed from true - expensive for learning
}

variable "enable_firewall" {
  description = "Enable Azure Firewall (~$900/month for Premium - can disable for learning)"
  type        = bool
  default     = false  # Changed from true - very expensive
}

variable "enable_bastion" {
  description = "Enable Azure Bastion (~$140/month - can disable for learning)"
  type        = bool
  default     = false  # Changed from true - moderate cost
}

variable "firewall_sku_tier" {
  description = "Azure Firewall SKU tier (Basic=~$0.20/hr, Standard=~$1.25/hr, Premium=~$1.35/hr)"
  type        = string
  default     = "Basic"  # Changed from Premium - much cheaper for learning
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.firewall_sku_tier)
    error_message = "Firewall SKU tier must be Basic, Standard, or Premium"
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    ManagedBy   = "Terraform"
    Environment = "prod"
    Purpose     = "LandingZone"
  }
}

variable "log_analytics_retention_days" {
  description = "Log Analytics retention in days (31+ costs extra, use 30 for free tier)"
  type        = number
  default     = 30  # Changed from 90 - stays within free tier
}

variable "private_dns_zones" {
  description = "List of private DNS zones to create"
  type        = list(string)
  default = [
    "privatelink.blob.core.windows.net",
    "privatelink.file.core.windows.net",
    "privatelink.queue.core.windows.net",
    "privatelink.table.core.windows.net",
    "privatelink.database.windows.net",
    "privatelink.sql.azuresynapse.net",
    "privatelink.vaultcore.azure.net",
    "privatelink.azurecr.io",
    "privatelink.azurewebsites.net",
    "privatelink.postgres.database.azure.com",
    "privatelink.mysql.database.azure.com"
  ]
}
