variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group in which to create the virtual network"
  type        = string
}

variable "subnet_name" {
  description = "Name of the first subnet"
  type        = string
}

variable "subnet_address_prefix" {
  description = "Address prefix of the subnet"
  type        = string
}
