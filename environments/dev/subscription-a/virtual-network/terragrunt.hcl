include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../modules/virtual-network"
}

dependency "resource_group" {
  config_path = "../resource-group"
  
  mock_outputs = {
    location            = "East US"
    resource_group_name = "mock-rg-name"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate"]
}

inputs = {
  vnet_name              = "vnet-dev-subscription-a"
  address_space          = ["10.1.0.0/16"]
  gateway_subnet_prefix  = ["10.1.255.0/27"]
  workload_subnet_prefix = ["10.1.1.0/24"]
  
  location            = dependency.resource_group.outputs.location
  resource_group_name = dependency.resource_group.outputs.resource_group_name
  
  tags = {
    Environment = "dev"
    Project     = "azure-vnet-vpn"
    Subscription = "subscription-a"
  }
}