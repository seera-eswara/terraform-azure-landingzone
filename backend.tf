terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "tfstatelzqiaypb"
    container_name       = "tfstate"
    key                  = "landingzone.tfstate"
    # Retry settings , possible causes for retries include eventual consistency of storage account creation,
    # GRS sometimes causes transient write failures during replication.
    # Azure may not fully propagate DNS + replication for 30–60 seconds.
    # A brief drop in your internet connection resets the PUT request.
    # Terraform uses your CLI token for backend auth.
    max_retries = 20
    retry_delay = "5s"
  }
}
