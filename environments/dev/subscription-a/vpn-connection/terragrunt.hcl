include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../modules/vpn-connection"
}

dependency "resource_group" {
  config_path = "../resource-group"

  mock_outputs = {
    location            = "East US"
    resource_group_name = "mock-rg-name"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate"]
}

dependency "vpn_gateway" {
  config_path = "../vpn-gateway"

  mock_outputs = {
    gateway_id = "/subscriptions/12345678-1234-9876-4563-123456789014/resourceGroups/example-resource-group/providers/Microsoft.Network/virtualNetworkGateways/virtualNetworkGatewayName"
  
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate"]
}

dependency "peer_vpn_gateway" {
  config_path = "../../subscription-b/vpn-gateway"

  mock_outputs = {
    gateway_id = "/subscriptions/12345678-1234-9876-4563-123456789015/resourceGroups/example-resource-group/providers/Microsoft.Network/virtualNetworkGateways/virtualNetworkGatewayName"
  
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate"]
}

inputs = {
  connection_name                    = "conn-dev-a-to-b"
  virtual_network_gateway_id         = dependency.vpn_gateway.outputs.gateway_id
  peer_virtual_network_gateway_id    = dependency.peer_vpn_gateway.outputs.gateway_id
  #shared_key                         = get_env("TF_VAR_vpn_shared_key", "DefaultSharedKey123!")
  
  location            = dependency.resource_group.outputs.location
  resource_group_name = dependency.resource_group.outputs.resource_group_name
  
  tags = {
    Environment = "dev"
    Project     = "azure-vnet-vpn"
    Subscription = "subscription-a"
  }
}