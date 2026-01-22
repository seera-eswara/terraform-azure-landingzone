# Bootstrap Backend Setup

This folder creates the Azure Storage Account and container for storing Terraform state files for the landing zone configuration.

## Purpose

- Creates a resource group for Terraform state storage
- Provisions a storage account with GRS replication
- Creates a private container for state files
- Generates backend configuration for the main landing zone

## Initial Setup (First Time Only)

### Prerequisites

- Azure CLI installed and authenticated (`az login`)
- Contributor access to the Azure subscription
- Terraform >= 1.5.0 installed

### Steps

1. **Initialize and apply bootstrap**:
   ```bash
   cd bootstrap/backend
   terraform init
   terraform plan
   terraform apply
   ```

   This creates:
   - Resource Group: `rg-tfstate`
   - Storage Account: `tfstatelz<random>` (e.g., `tfstatelzqiaypb`)
   - Container: `tfstate`

2. **Generate backend configuration**:
   ```bash
   ./generate-backend-config.sh
   ```

   This automatically creates/updates the `backend.tf` file in the parent directory with the correct storage account name.

3. **Initialize the main landing zone configuration**:
   ```bash
   cd ../../  # Back to terraform-azure-landingzone/
   terraform init
   ```

## Why This Two-Step Process?

**Chicken-and-Egg Problem**: You can't store state remotely until the remote storage exists.

- **Step 1**: Bootstrap uses **local state** to create the storage account
- **Step 2**: Main landing zone uses **remote state** (the storage account from Step 1)

## Manual Backend Configuration

If you prefer not to use the script, copy the outputs manually:

```bash
cd bootstrap/backend
terraform output resource_group_name
terraform output storage_account_name
terraform output container_name
```

Then update `../../backend.tf` with these values.

## State File Location

- Bootstrap state: `bootstrap/backend/terraform.tfstate` (local)
- Landing zone state: Azure Storage (remote) at `landingzone.tfstate`

## Important Notes

- **Keep bootstrap state safe**: The `bootstrap/backend/terraform.tfstate` file is critical - it tracks the storage account resource
- **Backup recommended**: Consider storing the bootstrap state in a secure location (encrypted, version-controlled separately)
- **Backend block limitations**: The `backend` configuration cannot use variables or data sources - must be literal values

## Troubleshooting

### Storage account name conflicts

If you get a conflict error, the random suffix collision occurred. Delete and re-run:
```bash
terraform destroy
terraform apply
```

### Access denied errors

Ensure your Azure CLI session has Contributor rights:
```bash
az account show
az role assignment list --assignee $(az ad signed-in-user show --query id -o tsv)
```

### Backend initialization errors

If `terraform init` fails in the main directory:
1. Verify the backend.tf values match the bootstrap outputs
2. Check storage account access permissions
3. Try: `terraform init -reconfigure`
