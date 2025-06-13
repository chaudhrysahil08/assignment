include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../modules/resource-group"
}

inputs = {
  resource_group_name = "rg-vpn-dev-subscription-a"
  location           = "East US"
  
  tags = {
    Environment = "dev"
    Project     = "azure-vnet-vpn"
    Subscription = "subscription-a"
  }
}