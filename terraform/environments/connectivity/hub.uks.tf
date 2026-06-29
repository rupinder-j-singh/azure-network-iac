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
  vnet_address_space  = "10.202.0.0/16"
  subnet_management   = "10.202.3.0/24"
  tags                = var.tags
}