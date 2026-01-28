# Azure Landing Zone Networking Module

This module deploys a complete hub-spoke network topology with Azure Firewall, Bastion, DDoS protection, and Private DNS zones.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                       Hub VNet (10.0.0.0/16)                │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │   Firewall   │  │   Bastion    │  │   Gateway    │    │
│  │  10.0.1.0/24 │  │  10.0.2.0/24 │  │  10.0.3.0/24 │    │
│  └──────────────┘  └──────────────┘  └──────────────┘    │
│                                                             │
│  ┌──────────────┐                                          │
│  │  Management  │                                          │
│  │  10.0.4.0/24 │                                          │
│  └──────────────┘                                          │
└──────────────┬───────────────────────────┬─────────────────┘
               │                           │
        VNet Peering              VNet Peering
               │                           │
    ┌──────────▼──────────┐    ┌──────────▼──────────┐
    │  Spoke VNet (App)   │    │  Spoke VNet (Data)  │
    │   10.1.0.0/16       │    │   10.2.0.0/16       │
    │                     │    │                     │
    │  - App Subnet       │    │  - DB Subnet        │
    │  - Data Subnet      │    │  - Cache Subnet     │
    └─────────────────────┘    └─────────────────────┘
```

## Features

### Hub VNet
- **Azure Firewall**: Premium tier with threat intelligence and intrusion detection
- **Azure Bastion**: Secure RDP/SSH access without public IPs
- **Gateway Subnet**: Ready for VPN/ExpressRoute
- **Management Subnet**: For jumpboxes and management VMs
- **DDoS Protection**: Enterprise-grade DDoS mitigation

### Spoke VNets
- **Automatic Peering**: Hub-spoke connectivity with transit routing
- **Route Tables**: All traffic routed through Azure Firewall
- **NSGs**: Default security rules with VNet-to-VNet allowed
- **Service Endpoints**: Configured per subnet
- **Private DNS**: All zones linked automatically

### Global Services
- **Private DNS Zones**: 11+ zones for Azure PaaS services
- **Log Analytics**: Centralized logging and monitoring
- **Diagnostic Settings**: Enabled on all network resources

## Usage

```hcl
module "networking" {
  source = "./networking"

  location    = "eastus"
  environment = "prod"

  hub_vnet_address_space = ["10.0.0.0/16"]

  spoke_vnets = {
    "spoke-app" = {
      address_space = ["10.1.0.0/16"]
      subnets = {
        "app-subnet" = {
          address_prefix    = "10.1.1.0/24"
          service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
        }
        "data-subnet" = {
          address_prefix    = "10.1.2.0/24"
          service_endpoints = ["Microsoft.Sql"]
        }
      }
    }
  }

  enable_firewall         = true
  enable_bastion          = true
  enable_ddos_protection  = true

  tags = {
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}
```

## Outputs

- `hub_vnet_id` - Hub VNet resource ID
- `spoke_vnet_ids` - Map of spoke VNet IDs
- `firewall_private_ip` - Firewall private IP (for routing)
- `log_analytics_workspace_id` - Central logging workspace
- `private_dns_zones` - Map of DNS zone IDs

## Private DNS Zones

The following zones are automatically created and linked:

- `privatelink.blob.core.windows.net` (Storage - Blob)
- `privatelink.file.core.windows.net` (Storage - File)
- `privatelink.queue.core.windows.net` (Storage - Queue)
- `privatelink.table.core.windows.net` (Storage - Table)
- `privatelink.database.windows.net` (Azure SQL)
- `privatelink.sql.azuresynapse.net` (Synapse)
- `privatelink.vaultcore.azure.net` (Key Vault)
- `privatelink.azurecr.io` (Container Registry)
- `privatelink.azurewebsites.net` (App Service)
- `privatelink.postgres.database.azure.com` (PostgreSQL)
- `privatelink.mysql.database.azure.com` (MySQL)

## Firewall Rules

### Default Network Rules
- Allow Azure Monitor (443)
- Allow Azure Storage (443)
- Allow Azure Key Vault (443)
- Allow DNS (53)

### Default Application Rules
- Allow Windows Updates
- Allow Azure Management APIs

## Cost Considerations

| Resource | Monthly Cost (Approx) |
|----------|---------------------|
| Azure Firewall Premium | ~$900 |
| DDoS Protection Plan | ~$2,944 |
| Azure Bastion Standard | ~$140 |
| Log Analytics (90-day retention) | Variable |
| **Total** | **~$4,000+/month** |

## Security

- All traffic routed through Azure Firewall
- NSGs applied to all spoke subnets
- DDoS protection on all VNets
- Bastion for secure VM access (no public IPs)
- Private DNS for Azure PaaS services
- Diagnostic logging on all resources

## Maintenance

### Adding a New Spoke VNet

```hcl
spoke_vnets = {
  # Existing spokes...
  
  "spoke-new" = {
    address_space = ["10.3.0.0/16"]
    subnets = {
      "app-subnet" = {
        address_prefix = "10.3.1.0/24"
      }
    }
  }
}
```

### Adding Firewall Rules

Edit the rule collection groups in `main.tf` to add custom network or application rules.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| azurerm | ~> 4.57.0 |
