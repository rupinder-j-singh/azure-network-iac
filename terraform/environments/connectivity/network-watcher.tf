# ============================================================
# Network Monitoring — VNet Flow Logs, Connection Monitor,
# Diagnostic Settings
# ============================================================

# ── Data sources ──────────────────────────────────────────────

data "azurerm_network_watcher" "uks" {
  name                = "NetworkWatcher_uksouth"
  resource_group_name = "NetworkWatcherRG"
}

data "azurerm_network_watcher" "ukw" {
  name                = "NetworkWatcher_ukwest"
  resource_group_name = "NetworkWatcherRG"
}

data "azurerm_log_analytics_workspace" "central" {
  name                = "log-rs-central-uks-p-001"
  resource_group_name = "rg-rs-mgmt-uks-p-001"
  provider            = azurerm.management
}

# ── VNet Flow Logs v2 — UK South ─────────────────────────────
# NSG flow logs retired June 2025 — VNet flow logs replacement
# Captures all traffic in/out of VNet including all subnets
# Version 2 includes bytes and packets transferred

resource "azurerm_network_watcher_flow_log" "vnet_uks" {
  name                 = "fl-rs-vnet-uks-p-001"
  network_watcher_name = data.azurerm_network_watcher.uks.name
  resource_group_name  = "NetworkWatcherRG"
  target_resource_id   = module.hub_uks.vnet_id
  storage_account_id   = azurerm_storage_account.diagnostics.id
  enabled              = true
  version              = 2

  retention_policy {
    enabled = true
    days    = 7
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = data.azurerm_log_analytics_workspace.central.workspace_id
    workspace_region      = "uksouth"
    workspace_resource_id = data.azurerm_log_analytics_workspace.central.id
    interval_in_minutes   = 10
  }

  tags = var.tags
}

# ── VNet Flow Logs v2 — UK West ───────────────────────────────
# No Traffic Analytics — Log Analytics workspace is in UK South
# Storage account must be in same region as Network Watcher

resource "azurerm_network_watcher_flow_log" "vnet_ukw" {
  name                 = "fl-rs-vnet-ukw-p-001"
  network_watcher_name = data.azurerm_network_watcher.ukw.name
  resource_group_name  = "NetworkWatcherRG"
  target_resource_id   = module.hub_ukw.vnet_id
  storage_account_id   = azurerm_storage_account.diagnostics_ukw.id
  enabled              = true
  version              = 2

  retention_policy {
    enabled = true
    days    = 7
  }

  traffic_analytics {
    enabled               = false
    workspace_id          = data.azurerm_log_analytics_workspace.central.workspace_id
    workspace_region      = "uksouth"
    workspace_resource_id = data.azurerm_log_analytics_workspace.central.id
    interval_in_minutes   = 60
  }

  tags = var.tags
}

# ── Diagnostic Settings — Hub VNet UK South ───────────────────
# Logs VNet operations — peering changes, config changes

resource "azurerm_monitor_diagnostic_setting" "vnet_uks" {
  name                       = "diag-vnet-uks-p-001"
  target_resource_id         = module.hub_uks.vnet_id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.central.id

  enabled_log {
    category = "VMProtectionAlerts"
  }
}

# ── Diagnostic Settings — Hub VNet UK West ────────────────────

resource "azurerm_monitor_diagnostic_setting" "vnet_ukw" {
  name                       = "diag-vnet-ukw-p-001"
  target_resource_id         = module.hub_ukw.vnet_id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.central.id

  enabled_log {
    category = "VMProtectionAlerts"
  }
}

# ── Diagnostic Settings — NSG UK South ───────────────────────
# Logs NSG rule change events and rule hit counters

resource "azurerm_monitor_diagnostic_setting" "nsg_uks" {
  name                       = "diag-nsg-mgmt-uks-p-001"
  target_resource_id         = module.hub_uks.nsg_management_id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.central.id

  enabled_log {
    category = "NetworkSecurityGroupEvent"
  }

  enabled_log {
    category = "NetworkSecurityGroupRuleCounter"
  }
}

# ── Diagnostic Settings — NSG UK West ────────────────────────

resource "azurerm_monitor_diagnostic_setting" "nsg_ukw" {
  name                       = "diag-nsg-mgmt-ukw-p-001"
  target_resource_id         = module.hub_ukw.nsg_management_id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.central.id

  enabled_log {
    category = "NetworkSecurityGroupEvent"
  }

  enabled_log {
    category = "NetworkSecurityGroupRuleCounter"
  }
}

# ── Diagnostic Settings — VM NIC ─────────────────────────────
# Logs NIC metrics — bytes in/out, packets, drops

resource "azurerm_monitor_diagnostic_setting" "nic_uks" {
  name                       = "diag-nic-plt-uks-p-001"
  target_resource_id         = azurerm_network_interface.jump_uks.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.central.id

  enabled_metric {
    category = "AllMetrics"
  }
}

# ── Connection Monitor — VM to Internet ──────────────────────
# Tests: can VM reach internet on TCP 443 and ICMP?
# Alerts if outbound connectivity lost

resource "azurerm_network_connection_monitor" "vm_to_internet" {
  name               = "cm-rs-vm-internet-uks-p-001"
  network_watcher_id = data.azurerm_network_watcher.uks.id
  location           = "uksouth"

  endpoint {
    name               = "source-rspltjmpp01"
    target_resource_id = azurerm_windows_virtual_machine.jump_uks.id
  }

  endpoint {
    name    = "dest-google-dns"
    address = "8.8.8.8"
  }

  endpoint {
    name    = "dest-microsoft"
    address = "microsoft.com"
  }

  test_configuration {
    name                      = "tcp-443"
    protocol                  = "Tcp"
    test_frequency_in_seconds = 60

    tcp_configuration {
      port                = 443
      trace_route_enabled = true
    }
  }

  test_configuration {
    name                      = "icmp-ping"
    protocol                  = "Icmp"
    test_frequency_in_seconds = 60

    icmp_configuration {
      trace_route_enabled = true
    }
  }

  test_group {
    name                     = "tg-internet-tcp"
    destination_endpoints    = ["dest-google-dns", "dest-microsoft"]
    source_endpoints         = ["source-rspltjmpp01"]
    test_configuration_names = ["tcp-443"]
    enabled                  = true
  }

  test_group {
    name                     = "tg-internet-icmp"
    destination_endpoints    = ["dest-google-dns"]
    source_endpoints         = ["source-rspltjmpp01"]
    test_configuration_names = ["icmp-ping"]
    enabled                  = true
  }

  tags       = var.tags
  depends_on = [azurerm_virtual_machine_extension.network_watcher]
}

# ── Connection Monitor — Hub UKS to Hub UKW ──────────────────
# Tests: is VNet peering working between regions?
# Uses ICMP to test connectivity to UK West management subnet
# Alerts if cross-region path breaks

resource "azurerm_network_connection_monitor" "hub_uks_to_ukw" {
  name               = "cm-rs-hub-uks-to-ukw-p-001"
  network_watcher_id = data.azurerm_network_watcher.uks.id
  location           = "uksouth"

  endpoint {
    name               = "source-rspltjmpp01"
    target_resource_id = azurerm_windows_virtual_machine.jump_uks.id
  }

  endpoint {
    name    = "dest-hub-ukw-mgmt"
    address = "10.204.15.1"
  }

  test_configuration {
    name                      = "icmp-peering"
    protocol                  = "Icmp"
    test_frequency_in_seconds = 60

    icmp_configuration {
      trace_route_enabled = true
    }
  }

  test_group {
    name                     = "tg-peering"
    destination_endpoints    = ["dest-hub-ukw-mgmt"]
    source_endpoints         = ["source-rspltjmpp01"]
    test_configuration_names = ["icmp-peering"]
    enabled                  = true
  }

  tags       = var.tags
  depends_on = [azurerm_virtual_machine_extension.network_watcher]
}

# ── Connection Monitor — VM to Log Analytics ──────────────────
# Tests: can VM reach Log Analytics endpoint?
# If this fails — monitoring pipeline is broken
# Meta-monitoring: monitoring your monitoring

resource "azurerm_network_connection_monitor" "vm_to_law" {
  name               = "cm-rs-vm-law-uks-p-001"
  network_watcher_id = data.azurerm_network_watcher.uks.id
  location           = "uksouth"

  endpoint {
    name               = "source-rspltjmpp01"
    target_resource_id = azurerm_windows_virtual_machine.jump_uks.id
  }

  endpoint {
    name    = "dest-log-analytics"
    address = "ods.opinsights.azure.com"
  }

  test_configuration {
    name                      = "tcp-law"
    protocol                  = "Tcp"
    test_frequency_in_seconds = 60

    tcp_configuration {
      port                = 443
      trace_route_enabled = true
    }
  }

  test_group {
    name                     = "tg-law"
    destination_endpoints    = ["dest-log-analytics"]
    source_endpoints         = ["source-rspltjmpp01"]
    test_configuration_names = ["tcp-law"]
    enabled                  = true
  }

  tags       = var.tags
  depends_on = [azurerm_virtual_machine_extension.network_watcher]
}