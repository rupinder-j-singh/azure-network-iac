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

variable "nsg_rules" {
  description = "NSG rules to apply to management subnet"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = []
}
variable "subnet_bastion" {
  description = "AzureBastionSubnet CIDR — /26 minimum required by Azure"
  type        = string
}

variable "subnet_pe" {
  description = "Private endpoints subnet CIDR"
  type        = string
}

variable "subnet_dns" {
  description = "DNS Private Resolver subnet CIDR"
  type        = string
}