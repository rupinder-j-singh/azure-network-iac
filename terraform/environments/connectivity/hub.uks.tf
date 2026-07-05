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
  vnet_address_space  = "10.202.0.0/20"
  subnet_management   = "10.202.15.0/24"
  subnet_bastion      = "10.202.14.0/24"
  subnet_pe           = "10.202.11.0/24"
  subnet_dns          = "10.202.10.0/24"
  tags                = var.tags

  nsg_rules = [
  {
    name                       = "allow-rdp-tailscale"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "100.64.0.0/10"
    destination_address_prefix = "*"
  },
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