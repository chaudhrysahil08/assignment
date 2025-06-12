output "gateway_id" {
  description = "ID of the VPN gateway"
  value       = azurerm_virtual_network_gateway.main.id
}

output "gateway_name" {
  description = "Name of the VPN gateway"
  value       = azurerm_virtual_network_gateway.main.name
}