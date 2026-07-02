# ============================================================
# Hub Network Module — Outputs
# ============================================================

output "resource_group_name" {
  description = "Hub resource group name"
  value       = azurerm_resource_group.hub.name
}

output "vnet_name" {
  description = "Hub VNet name"
  value       = azurerm_virtual_network.hub.name
}

output "vnet_id" {
  description = "Hub VNet ID — used for peering"
  value       = azurerm_virtual_network.hub.id
}

output "subnet_management_id" {
  description = "Management subnet ID"
  value       = azurerm_subnet.management.id
}

output "nsg_management_id" {
  description = "Management subnet NSG ID"
  value       = azurerm_network_security_group.management.id
}