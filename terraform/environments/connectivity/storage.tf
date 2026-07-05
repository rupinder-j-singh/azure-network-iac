# ============================================================
# Diagnostics Storage — Connectivity Subscription
# ============================================================

resource "azurerm_resource_group" "diagnostics" {
  name     = "rg-${var.entity}-diag-uks-p-001"
  location = "uksouth"

  tags = merge(var.tags, {
    application = "diagnostics"
  })
}

resource "azurerm_storage_account" "diagnostics" {
  name                            = "strs${var.entity}conndiaguksp01"
  resource_group_name             = azurerm_resource_group.diagnostics.name
  location                        = azurerm_resource_group.diagnostics.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 7
    }
  }

  tags = merge(var.tags, {
    application = "diagnostics"
  })
}