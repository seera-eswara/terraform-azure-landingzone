# Data source to reference existing backend storage created by bootstrap
# These data sources allow you to reference the backend storage in your code
# Note: The backend {} block in backend.tf cannot use these - it requires literal values

data "azurerm_resource_group" "tfstate" {
  name = "rg-tfstate"
}

data "azurerm_storage_account" "tfstate" {
  name                = "tfstatelzqiaypb"  # Update this with actual name from: terraform -chdir=bootstrap/backend output storage_account_name
  resource_group_name = data.azurerm_resource_group.tfstate.name
}

data "azurerm_storage_container" "tfstate" {
  name                 = "tfstate"
  storage_account_name = data.azurerm_storage_account.tfstate.name
}

# Optional: Output these for reference
output "backend_storage_info" {
  description = "Information about the backend storage"
  value = {
    resource_group_name  = data.azurerm_resource_group.tfstate.name
    storage_account_name = data.azurerm_storage_account.tfstate.name
    container_name       = data.azurerm_storage_container.tfstate.name
    location             = data.azurerm_storage_account.tfstate.location
  }
}
