variable "gateway_name" {
  description = "Name of the VPN gateway"
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

variable "gateway_sku" {
  description = "SKU of the VPN gateway"
  type        = string
  default     = "VpnGw1"
}

variable "public_ip_id" {
  description = "ID of the public IP for the gateway"
  type        = string
}

variable "gateway_subnet_id" {
  description = "ID of the gateway subnet"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}