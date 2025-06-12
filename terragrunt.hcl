# terragrunt.hcl - Root configuration
locals {
  # Common variables across all environments
  common_vars = {
    project_name = "azure-vnet-vpn"
    owner        = "infrastructure-team"
  }
  
  # Parse environment and subscription from path
  parsed = regex("environments/(?P<environment>[^/]+)/(?P<subscription>[^/]+)", path_relative_to_include())
  environment = local.parsed.environment
  subscription = "85659bb0-6be4-44fb-be6d-f46301b046d4"
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
    key                  = "${local.subscription}/${path_relative_to_include()}/terraform.tfstate"
  }
}

# Generate random suffix for storage account name
/*generate "random_suffix" {
  path      = "random.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
resource "random_id" "storage_suffix" {
  byte_length = 4
}
EOF
}*/

# Generate provider configuration - FIXED VERSION
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
  subscription_id = "85659bb0-6be4-44fb-be6d-f46301b046d4"
}
EOF
}

# Common inputs for all configurations
inputs = merge(
  local.common_vars,
  {
    environment = local.environment
    subscription_name = local.subscription
  }
)