#!/bin/bash
# Script to generate backend configuration after bootstrap
# Run this after: terraform apply in bootstrap/backend/

set -e

echo "Fetching backend configuration from Terraform outputs..."

RG_NAME=$(terraform output -raw resource_group_name)
SA_NAME=$(terraform output -raw storage_account_name)
CONTAINER_NAME=$(terraform output -raw container_name)

echo ""
echo "========================================="
echo "Backend Configuration Generated"
echo "========================================="
echo ""
echo "Copy this into terraform-azure-landingzone/backend.tf:"
echo ""
cat <<EOF
terraform {
  backend "azurerm" {
    resource_group_name  = "$RG_NAME"
    storage_account_name = "$SA_NAME"
    container_name       = "$CONTAINER_NAME"
    key                  = "landingzone.tfstate"
    max_retries          = 20
    retry_delay          = "5s"
  }
}
EOF
echo ""
echo "========================================="
echo ""

# Optionally write to file
cat > ../../backend.tf <<BACKEND_EOF
terraform {
  backend "azurerm" {
    resource_group_name  = "$RG_NAME"
    storage_account_name = "$SA_NAME"
    container_name       = "$CONTAINER_NAME"
    key                  = "landingzone.tfstate"
    max_retries          = 20
    retry_delay          = "5s"
  }
}
BACKEND_EOF

echo "✅ backend.tf has been updated in terraform-azure-landingzone/"
echo ""
echo "Next steps:"
echo "1. cd ../../"
echo "2. terraform init -reconfigure"
echo "3. terraform plan"
