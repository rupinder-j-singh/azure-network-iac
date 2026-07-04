# ============================================================
# Hub Network Module — Main
# ============================================================

resource "azurerm_resource_group" "hub" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-${var.entity}-hub-${var.location_code}-${var.environment}-001"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = [var.vnet_address_space]
  tags                = var.tags
}

resource "azurerm_subnet" "management" {
  name                 = "snet-${var.entity}-mgmt-${var.location_code}-${var.environment}-001"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.subnet_management]
}

# ── NSG — Management Subnet ───────────────────────────────────
resource "azurerm_network_security_group" "management" {
  name                = "nsg-${var.entity}-mgmt-${var.location_code}-${var.environment}-001"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  tags                = var.tags

  dynamic "security_rule" {
    for_each = var.nsg_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "management" {
  subnet_id                 = azurerm_subnet.management.id
  network_security_group_id = azurerm_network_security_group.management.id
}
# ── Bastion Subnet ────────────────────────────────────────────
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.subnet_bastion]
}

# ── Private Endpoints Subnet ──────────────────────────────────
resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-${var.entity}-pe-${var.location_code}-${var.environment}-001"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.subnet_pe]
}

# ── DNS Resolver Subnet ───────────────────────────────────────
resource "azurerm_subnet" "dns_resolver" {
  name                 = "snet-${var.entity}-dns-${var.location_code}-${var.environment}-001"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.subnet_dns]

  delegation {
    name = "dns-resolver-delegation"
    service_delegation {
      name    = "Microsoft.Network/dnsResolvers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}