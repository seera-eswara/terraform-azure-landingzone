# App Spoke VNet Integration Guide

## Overview

This guide explains how app teams integrate their spoke VNet with the platform hub network.

## Architecture Pattern: App-Owned Spoke VNet

```
┌─────────────────────────────────────────────────────────────┐
│         Platform Landing Zone (Cloud Team Owned)            │
│                                                              │
│  Hub VNet (10.0.0.0/16)                                     │
│  ├── Azure Firewall (10.0.1.0/24)                          │
│  ├── Bastion (10.0.2.0/24)                                 │
│  ├── Gateway Subnet (10.0.3.0/24)                          │
│  └── Private DNS Zones                                      │
│                                                              │
└──────────────────────────┬───────────────────────────────────┘
                           │ VNet Peering
                           │
┌──────────────────────────▼───────────────────────────────────┐
│       RFF-React Subscription (App Team Owned)                │
│                                                              │
│  Spoke VNet (10.10.0.0/16)                                  │
│  ├── App Subnet (10.10.1.0/24)                             │
│  │   └── Static Web App, Functions, etc.                    │
│  ├── Data Subnet (10.10.2.0/24)                            │
│  │   └── SQL, Cosmos, Redis, etc.                           │
│  └── Route Tables → Firewall (10.0.1.4)                    │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

## Integration Steps

### 1. App Team: Create Spoke VNet

When you onboard a new app/module, the `devops-automation` scaffolding will include `networking.tf` in your infra repo.

**Example: rff-react-infra/envs/dev/terraform.tfvars**

```hcl
# Networking Configuration
vnet_address_space         = "10.10.0.0/16"    # Unique per app
app_subnet_address_prefix  = "10.10.1.0/24"
data_subnet_address_prefix = "10.10.2.0/24"

app_subnet_service_endpoints = [
  "Microsoft.Storage",
  "Microsoft.KeyVault",
  "Microsoft.Web"
]

data_subnet_service_endpoints = [
  "Microsoft.Sql",
  "Microsoft.Storage",
  "Microsoft.KeyVault"
]
```

### 2. App Team: Deploy Infrastructure

```bash
cd rff-react-infra/envs/dev
terraform init
terraform plan
terraform apply
```

This creates:
- ✅ Spoke VNet in your subscription
- ✅ App and Data subnets
- ✅ NSGs with default rules
- ✅ Route table pointing to firewall
- ✅ Peering from spoke → hub

**Note the output:**
```bash
terraform output vnet_id
# Output: /subscriptions/.../virtualNetworks/vnet-rff-react-dev
```

### 3. Cloud Team: Accept Peering

Cloud team adds your spoke to the landing zone:

**terraform-azure-landingzone/terraform.tfvars**

```hcl
app_spoke_vnets = {
  "rff-react-dev" = {
    vnet_id = "/subscriptions/xxx/resourceGroups/rg-rff-react-dev/providers/Microsoft.Network/virtualNetworks/vnet-rff-react-dev"
  }
  "rff-react-stage" = {
    vnet_id = "/subscriptions/yyy/resourceGroups/rg-rff-react-stage/providers/Microsoft.Network/virtualNetworks/vnet-rff-react-stage"
  }
  "rff-react-prod" = {
    vnet_id = "/subscriptions/zzz/resourceGroups/rg-rff-react-prod/providers/Microsoft.Network/virtualNetworks/vnet-rff-react-prod"
  }
}
```

```bash
cd terraform-azure-landingzone
terraform plan
terraform apply
```

This creates:
- ✅ Peering from hub → spoke
- ✅ Private DNS zones linked to spoke

### 4. Verify Connectivity

```bash
# From app subnet, verify you can reach Azure services through firewall
# Check firewall logs to see traffic flow
```

## CIDR Block Allocation

To avoid IP overlap, coordinate with the cloud team:

| App Code | Environment | VNet CIDR | App Subnet | Data Subnet |
|----------|-------------|-----------|------------|-------------|
| RFF-React | Dev | 10.10.0.0/16 | 10.10.1.0/24 | 10.10.2.0/24 |
| RFF-React | Stage | 10.11.0.0/16 | 10.11.1.0/24 | 10.11.2.0/24 |
| RFF-React | Prod | 10.12.0.0/16 | 10.12.1.0/24 | 10.12.2.0/24 |
| App2 | Dev | 10.20.0.0/16 | 10.20.1.0/24 | 10.20.2.0/24 |

## What You Get

### Traffic Routing
- All outbound traffic (0.0.0.0/0) → Azure Firewall
- Firewall enforces security policies
- Internet access controlled centrally

### Private DNS
- All Azure PaaS private endpoints resolve correctly
- No manual DNS configuration needed
- Automatic propagation from hub

### Security
- NSGs applied to all subnets
- Default deny internet to data subnet
- All traffic logged to Log Analytics

### Monitoring
- VNet diagnostics → Log Analytics
- NSG flow logs → Log Analytics
- Integrated with platform monitoring

## Troubleshooting

### Cannot reach Azure services
- Verify route table has default route to firewall
- Check firewall rules allow your traffic
- Verify NSG rules don't block outbound

### Peering not working
- Ensure spoke → hub peering is "Connected"
- Ask cloud team to verify hub → spoke peering
- Check CIDR ranges don't overlap

### DNS resolution fails
- Verify private DNS zones are linked to your spoke
- Check VNet DNS settings point to Azure-provided DNS

## Support

- **Network CIDR Allocation**: Contact cloud team before deploying
- **Firewall Rules**: Submit requests via [GitHub issues]
- **Peering Setup**: Cloud team will configure after you deploy spoke
- **General Questions**: #platform-networking Slack channel

## Example Apps

- [app1-infra](../../app1-infra/) - Reference implementation
- [rff-react-infra](../../rff-react-infra/) - React module example (when created)
