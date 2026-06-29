# ============================================================
# Connectivity Environment — Outputs
# ============================================================

output "hub_uks_vnet_id" {
  description = "UK South hub VNet ID"
  value       = module.hub_uks.vnet_id
}

output "hub_uks_vnet_name" {
  description = "UK South hub VNet name"
  value       = module.hub_uks.vnet_name
}

output "hub_uks_rg_name" {
  description = "UK South hub resource group name"
  value       = module.hub_uks.resource_group_name
}

output "hub_ukw_vnet_id" {
  description = "UK West hub VNet ID"
  value       = module.hub_ukw.vnet_id
}

output "hub_ukw_vnet_name" {
  description = "UK West hub VNet name"
  value       = module.hub_ukw.vnet_name
}

output "hub_ukw_rg_name" {
  description = "UK West hub resource group name"
  value       = module.hub_ukw.resource_group_name
}