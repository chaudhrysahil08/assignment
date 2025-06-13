output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "gateway_subnet_id" {
  description = "ID of the gateway subnet"
  value       = azurerm_subnet.gateway.id
}

output "gateway_public_ip_id" {
  description = "ID of the gateway public IP"
  value       = azurerm_public_ip.gateway.id
}

output "gateway_public_ip_address" {
  description = "Public IP address of the gateway"
  value       = azurerm_public_ip.gateway.ip_address
}