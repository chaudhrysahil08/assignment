resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  
  tags = var.tags
}

resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.gateway_subnet_prefix
}

resource "azurerm_subnet" "workload" {
  name                 = var.workload_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.workload_subnet_prefix
}

resource "azurerm_public_ip" "gateway" {
  name                = "${var.vnet_name}-gateway-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  
  tags = var.tags
}