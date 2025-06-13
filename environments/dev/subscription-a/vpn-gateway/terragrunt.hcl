include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../modules/vpn-gateway"
}

dependency "resource_group" {
  config_path = "../resource-group"

  mock_outputs = {
    location            = "East US"
    resource_group_name = "mock-rg-name"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate"]
}

dependency "virtual_network" {
  config_path = "../virtual-network"

  mock_outputs = {
    gateway_public_ip_id = "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/example-resource-group/providers/Microsoft.Network/publicIPAddresses/248.27.219.214"
    gateway_subnet_id    = "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/rg-mock/providers/Microsoft.Network/virtualNetworks/mock-vnet/subnets/GatewaySubnet"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate"]
}

inputs = {
  gateway_name        = "vgw-dev-subscription-a"
  gateway_sku         = "VpnGw1"
  
  location            = dependency.resource_group.outputs.location
  resource_group_name = dependency.resource_group.outputs.resource_group_name
  public_ip_id        = dependency.virtual_network.outputs.gateway_public_ip_id
  gateway_subnet_id   = dependency.virtual_network.outputs.gateway_subnet_id
  
  tags = {
    Environment = "dev"
    Project     = "azure-vnet-vpn"
    Subscription = "subscription-a"
  }
}