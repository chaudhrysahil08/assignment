variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "gateway_subnet_prefix" {
  description = "Address prefix for the gateway subnet"
  type        = list(string)
}

variable "workload_subnet_name" {
  description = "Name of the workload subnet"
  type        = string
  default     = "workload-subnet"
}

variable "workload_subnet_prefix" {
  description = "Address prefix for the workload subnet"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}