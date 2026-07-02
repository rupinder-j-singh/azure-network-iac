# ============================================================
# Hub Network — UK West (DR)
# ============================================================

module "hub_ukw" {
  source = "../../modules/hub-network"

  entity              = var.entity
  location            = "ukwest"
  location_code       = "ukw"
  environment         = var.environment
  resource_group_name = "rg-${var.entity}-hub-ukw-${var.environment}-001"
  vnet_address_space  = "10.204.0.0/20"
  subnet_management   = "10.204.15.0/24"
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