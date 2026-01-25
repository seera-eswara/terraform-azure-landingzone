# Landing Zone - Policy Deployment

This document describes how governance policies are deployed and managed in the Azure landing zone.

## Overview

The landing zone automatically deploys Azure Policies to enforce governance standards across all management groups and subscriptions.

## Policy Sources

Policies are sourced from [terraform-policy-as-code](../../../terraform-policy-as-code/README.md) repository.

**Current Policies Deployed**:
- ✅ Allowed VM SKUs
- ✅ Naming Convention
- ✅ Additional policies from policy-as-code repo

## Architecture

```
terraform-azure-landingzone/
├── management-groups/
│   ├── main.tf (Creates MG hierarchy)
│   ├── policies.tf (Deploys policies) ← THIS FILE
│   └── outputs.tf (Exports MG IDs)
│
└── References terraform-policy-as-code:
    ├── Reads policy definitions
    └── Assigns to cloud & LandingZones MGs
```

## Deployment Flow

```
1. terraform-azure-landingzone apply
   ├─ Creates cloud & LandingZones MGs
   ├─ Queries policy definitions from Azure
   ├─ Assigns policies to each MG
   └─ Policies cascade to child subscriptions (inherited)

2. New subscription created (via factory)
   └─ Automatically inherits policies from parent MG

3. New resource deployed (app team)
   ├─ Azure Policy engine evaluates resource
   ├─ If violates policy: Deployment blocked (Deny effect)
   └─ If complies: Deployment allowed
```

## Policy Assignments

### cloud Management Group

| Policy | Effect | Scope |
|--------|--------|-------|
| Allowed VM SKUs | Deny | Infrastructure resources |
| Naming Convention | Deny | All resources |

**Allowed VM SKUs for cloud**:
- Standard_B2ts_v2
- Standard_D2s_v3
- Standard_D4s_v3
- Standard_B4ms

### LandingZones Management Group

| Policy | Effect | Scope |
|--------|--------|-------|
| Allowed VM SKUs | Deny | App team resources |
| Naming Convention | Deny | All app resources |

**Allowed VM SKUs for Apps**:
- Standard_B2ts_v2
- Standard_D2s_v3
- Standard_D4s_v3
- Standard_B4ms
- Standard_F2s_v2

## How to Update Policies

### Option 1: Update Policy Version (Recommended)

When [terraform-policy-as-code](../../../terraform-policy-as-code/README.md) releases a new version:

```bash
cd terraform-azure-landingzone/management-groups

# Update your code to reference new policy version
# (Currently policies are referenced by name, not version)

# Apply changes
terraform apply

# All subscriptions automatically get new policy rules
```

### Option 2: Change Policy Parameters

Adjust allowed regions, SKUs, or other parameters:

```hcl
# management-groups/policies.tf

resource "azurerm_management_group_policy_assignment" "cloud_allowed_skus" {
  # ... existing config ...

  parameters = jsonencode({
    allowedSkus = {
      value = [
        "Standard_D4s_v3",    # ← Add new SKU here
        "Standard_D8s_v3",    # ← New SKU
        # ... existing SKUs ...
      ]
    }
  })
}

# Apply
terraform apply
```

### Option 3: Add New Policy

Get policy definition ID and create new assignment:

```hcl
# First, check available policies in Azure
data "azurerm_policy_definition" "new_policy" {
  name = "policy-name"
}

# Create assignment
resource "azurerm_management_group_policy_assignment" "cloud_new_policy" {
  name                 = "cloud-new-policy"
  policy_definition_id = data.azurerm_policy_definition.new_policy.id
  management_group_id  = azurerm_management_group.cloud.id

  parameters = jsonencode({
    # Policy-specific parameters
  })
}

# Apply
terraform apply
```

## Policy Compliance

### Check Compliance

```bash
# Azure Portal
Management Groups → <MG Name> → Policies → Compliance

# Or via Azure CLI
az policy assignment list --management-group <mg-id>
az policy state summarize --management-group <mg-id>
```

### View Non-Compliant Resources

```bash
az policy state list \
  --filter "resourceType eq 'Microsoft.Compute/virtualMachines'" \
  --query "[?complianceState=='NonCompliant']"
```

## Troubleshooting

### Issue: Policy assignment fails

**Error**: `Policy definition not found`

**Solution**: Ensure policy exists in Azure Policy service:
```bash
az policy definition list --query "[?name=='policy-name']"
```

### Issue: Policy not cascading to subscriptions

**Diagnosis**: Check parent-child MG relationship
```bash
az management group show --name <child-mg> --expand

# Verify parent_id is set correctly
```

### Issue: Resource deployment blocked by policy

**Solution**: 
1. Check which policy is blocking
2. Review policy rule in [terraform-policy-as-code](../../../terraform-policy-as-code/README.md/policies/definitions/)
3. Either:
   - Update resource to comply with policy
   - Request policy exemption (via governance process)
   - Update policy parameters

## Integration with Subscription Factory

When a new subscription is created:

```
terraform-azure-subscription-factory apply
│
├─ Creates subscription
├─ Assigns to management group under LandingZones
└─ Policies inherited automatically ← Policies from this deployment cascade here
```

New resources deployed in that subscription will automatically comply with policies (or fail if non-compliant).

## Integration with CI/CD

App teams validate against policies before deployment:

```
app1-infra/.github/workflows/iac-pipeline.yml
│
├─ terraform plan → plan.json
├─ conftest validate ← Uses rules from terraform-policy-as-code/opa/
└─ Policy violations fail the build
```

Example:
```bash
$ terraform plan -out=tfplan
$ conftest test tfplan -p terraform-policy-as-code/opa/

FAIL - Resource name must match naming convention: acme-app-resource-region
```

## References

- [terraform-policy-as-code](../../../terraform-policy-as-code/README.md)
- [Azure Policy Documentation](https://learn.microsoft.com/en-us/azure/governance/policy/)
- [Azure Management Groups](https://learn.microsoft.com/en-us/azure/governance/management-groups/)

## Next Steps

1. **Update terraform-policy-as-code** with new policies as needed
2. **Re-deploy landing zone** to apply new policies
3. **Monitor compliance** in Azure Portal
4. **Review exemptions** quarterly
5. **Update documentation** as policies evolve

---

**Last Updated**: January 18, 2026  
**Maintained By**: Infrastructure Team
