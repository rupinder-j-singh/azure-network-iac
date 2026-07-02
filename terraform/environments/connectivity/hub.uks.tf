# ============================================================
# Hub Network — UK South
# ============================================================

module "hub_uks" {
  source = "../../modules/hub-network"

  entity              = var.entity
  location            = "uksouth"
  location_code       = "uks"
  environment         = var.environment
  resource_group_name = "rg-${var.entity}-hub-uks-${var.environment}-001"
  vnet_address_space = "10.202.0.0/20"
  subnet_management  = "10.202.15.0/24"
  tags                = var.tags

  nsg_rules = [
    {
      name                       = "deny-all-inbound"
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
}