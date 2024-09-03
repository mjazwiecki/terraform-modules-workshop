variable "subscription_id" {
  description = "The subscription ID to use"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "resource_group_location" {
  description = "The location of the resource group"
  type        = string
  default     = "West Europe"
}

variable "common_tags" {
  type        = map(string)
  description = "Tags to apply."
  default = {
    Provisioner = "Terraform"
    Environment = "Workshop"
  }
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space of the virtual network"
  type        = list(string)
}

variable "subnet_name" {
  description = "Name of the first subnet"
  type        = string
}

variable "subnet_address_prefix" {
  description = "Address prefix of the subnet"
  type        = string
}
