# ============================================================
# Hub Network Module — Variables
# ============================================================

variable "entity" {
  description = "Entity code e.g. rs, cuk, jgl"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "location_code" {
  description = "Region code used in resource names"
  type        = string
}

variable "environment" {
  description = "Environment code"
  type        = string
}

variable "resource_group_name" {
  description = "Hub resource group name"
  type        = string
}

variable "vnet_address_space" {
  description = "Hub VNet address space"
  type        = string
}

variable "subnet_management" {
  description = "Management subnet CIDR"
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}