resource "azurerm_virtual_network_gateway_connection" "main" {
  name                = var.connection_name
  location            = var.location
  resource_group_name = var.resource_group_name
  
  type                            = "Vnet2Vnet"
  virtual_network_gateway_id      = var.virtual_network_gateway_id
  peer_virtual_network_gateway_id = var.peer_virtual_network_gateway_id
  
  shared_key = var.shared_key
  
  tags = var.tags
}