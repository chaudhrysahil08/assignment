output "connection_id" {
  description = "ID of the VPN connection"
  value       = azurerm_virtual_network_gateway_connection.main.id
}

output "connection_name" {
  description = "Name of the VPN connection"
  value       = azurerm_virtual_network_gateway_connection.main.name
}