resource "azurerm_virtual_network_gateway" "main" {
  name                = var.gateway_name
  location            = var.location
  resource_group_name = var.resource_group_name
  
  type     = "Vpn"
  vpn_type = "RouteBased"
  
  active_active = false
  enable_bgp    = false
  sku           = var.gateway_sku
  
  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = var.public_ip_id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.gateway_subnet_id
  }
  
  tags = var.tags
}