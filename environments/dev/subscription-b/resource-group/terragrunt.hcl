include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../modules/resource-group"
}

inputs = {
  resource_group_name = "rg-vpn-dev-subscription-b"
  location           = "West US 2"
  
  tags = {
    Environment = "dev"
    Project     = "azure-vnet-vpn"
    Subscription = "subscription-b"
  }
}