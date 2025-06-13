locals {
  # Common variables across all environments
  common_vars = {
    project_name = "azure-vnet-vpn"
    owner        = "infrastructure-team"
  }
  
  # Parse environment and subscription from path
  parsed = regex("environments/(?P<environment>[^/]+)/(?P<subscription>[^/]+)", path_relative_to_include())
  environment = local.parsed.environment
  subscription_folder = local.parsed.subscription
  
subscription_mapping = {
  # Dev subscriptions
  "dev-subscription-a" = "12345678-1234-9876-4563-123456789015"
  "dev-subscription-b" = "12345678-1234-9876-4563-123456789016"
  # Prod subscriptions
  #"prod-subscription-a" = "abcdef12-3456-7890-abcd-ef1234567890"
  #"prod-subscription-b" = "fedcba09-8765-4321-fedc-ba0987654321"
}

# Then use environment-aware folder names
subscription_key = "${local.environment}-${local.subscription_folder}"
subscription_id = local.subscription_mapping[local.subscription_key]
}

# Remote state configuration
remote_state {
  backend = "azurerm"
  
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  
  config = {
    resource_group_name  = "rg-terraform-state-${local.environment}"
    storage_account_name = "satfstate${local.environment}02"
    container_name       = "tfstate"
    key                  = "${local.subscription_id}/${path_relative_to_include()}/terraform.tfstate"
  }
}

# Generate provider configuration
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "${local.subscription_id}"
}
EOF
}

# Common inputs for all configurations
inputs = merge(
  local.common_vars,
  {
    environment = local.environment
    subscription_id = local.subscription_id
    subscription_name = local.subscription_folder
  }
)