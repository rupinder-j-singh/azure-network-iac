# ============================================================
# VNet Peering — Hub UK South ↔ Hub UK West
# ============================================================

# ── UK South → UK West ───────────────────────────────────────
resource "azurerm_virtual_network_peering" "uks_to_ukw" {
  name                         = "peer-rs-hub-uks-to-ukw-p-001"
  resource_group_name          = module.hub_uks.resource_group_name
  virtual_network_name         = module.hub_uks.vnet_name
  remote_virtual_network_id    = module.hub_ukw.vnet_id
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# ── UK West → UK South ───────────────────────────────────────
resource "azurerm_virtual_network_peering" "ukw_to_uks" {
  name                         = "peer-rs-hub-ukw-to-uks-p-001"
  resource_group_name          = module.hub_ukw.resource_group_name
  virtual_network_name         = module.hub_ukw.vnet_name
  remote_virtual_network_id    = module.hub_uks.vnet_id
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}