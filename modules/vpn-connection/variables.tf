variable "connection_name" {
  description = "Name of the VPN connection"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "virtual_network_gateway_id" {
  description = "ID of the local virtual network gateway"
  type        = string
}

variable "peer_virtual_network_gateway_id" {
  description = "ID of the peer virtual network gateway"
  type        = string
}

variable "shared_key" {
  description = "Shared key for the VPN connection"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}