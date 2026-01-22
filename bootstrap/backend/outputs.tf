output "resource_group_name" {
  description = "Resource group containing the Terraform state storage"
  value       = azurerm_resource_group.tfstate.name
}

output "storage_account_name" {
  description = "Storage account name for Terraform state"
  value       = azurerm_storage_account.tfstate.name
}

output "container_name" {
  description = "Container name for Terraform state"
  value       = azurerm_storage_container.tfstate.name
}

output "storage_account_primary_access_key" {
  description = "Primary access key for storage account (sensitive)"
  value       = azurerm_storage_account.tfstate.primary_access_key
  sensitive   = true
}

output "backend_config" {
  description = "Backend configuration for copy-paste into other Terraform configs"
  value = {
    resource_group_name  = azurerm_resource_group.tfstate.name
    storage_account_name = azurerm_storage_account.tfstate.name
    container_name       = azurerm_storage_container.tfstate.name
  }
}
