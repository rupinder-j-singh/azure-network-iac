# ============================================================
# Platform Jump Server — UK South
# rspltjmpp01 — Windows Server 2025
# ============================================================

# ── Data sources ──────────────────────────────────────────────
data "azurerm_client_config" "current" {}

data "azurerm_monitor_data_collection_rule" "windows" {
  name                = "dcr-rs-windows-uks-a-001"
  resource_group_name = "rg-rs-mgmt-uks-p-001"
  provider            = azurerm.management
}

# ── Random password — unique per VM ──────────────────────────
resource "random_password" "jump_uks" {
  length           = 20
  special          = true
  override_special = "!#$%&*()-_=+[]{}?"
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
}

# ── Key Vault — platform secrets ──────────────────────────────
resource "azurerm_key_vault" "platform" {
  name                       = "kv-rs-plt-uks-p-001"
  location                   = "uksouth"
  resource_group_name        = module.hub_uks.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = false
  soft_delete_retention_days = 7
  rbac_authorization_enabled = true

  tags = var.tags
}

# RBAC — pipeline SP can manage secrets
resource "azurerm_role_assignment" "kv_admin_sp" {
  scope                = azurerm_key_vault.platform.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = var.pipeline_sp_object_id
}

# RBAC — your user can manage secrets locally
resource "azurerm_role_assignment" "kv_admin_user" {
  scope                = azurerm_key_vault.platform.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Store generated password in Key Vault
resource "azurerm_key_vault_secret" "vm_password" {
  name         = "rspltjmpp01-admin-password"
  value        = random_password.jump_uks.result
  key_vault_id = azurerm_key_vault.platform.id

  depends_on = [
    azurerm_role_assignment.kv_admin_sp,
    azurerm_role_assignment.kv_admin_user
  ]
}

# ── Network Interface ─────────────────────────────────────────
resource "azurerm_network_interface" "jump_uks" {
  name                = "nic-rs-plt-uks-p-001"
  location            = "uksouth"
  resource_group_name = module.hub_uks.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.hub_uks.subnet_management_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

# ── Windows Server 2025 VM ────────────────────────────────────
resource "azurerm_windows_virtual_machine" "jump_uks" {
  name                  = "rspltjmpp01"
  location              = "uksouth"
  resource_group_name   = module.hub_uks.resource_group_name
  size                  = "Standard_B2s"
  admin_username        = "localadm"
  admin_password        = random_password.jump_uks.result
  network_interface_ids = [azurerm_network_interface.jump_uks.id]
  patch_mode    = "AutomaticByPlatform"
  hotpatching_enabled = true

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 128
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-datacenter-azure-edition"
    version   = "latest"
  }

 boot_diagnostics {
  storage_account_uri = azurerm_storage_account.diagnostics.primary_blob_endpoint
}

  tags = var.tags
}

# ── RBAC — VM managed identity reads Key Vault secrets ────────
resource "azurerm_role_assignment" "kv_vm" {
  scope                = azurerm_key_vault.platform.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_windows_virtual_machine.jump_uks.identity[0].principal_id
}

# ── Entra ID login — primary authentication ───────────────────
resource "azurerm_virtual_machine_extension" "aad_login" {
  name                       = "AADLoginForWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.jump_uks.id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "2.0"
  auto_upgrade_minor_version = true

  tags = var.tags
}

# ── RBAC — your account can login as admin via Entra ID ───────
resource "azurerm_role_assignment" "vm_admin_login" {
  scope                = azurerm_windows_virtual_machine.jump_uks.id
  role_definition_name = "Virtual Machine Administrator Login"
  principal_id         = data.azurerm_client_config.current.object_id
}

# ── Auto shutdown at 23:00 ────────────────────────────────────
resource "azurerm_dev_test_global_vm_shutdown_schedule" "jump_uks" {
  virtual_machine_id    = azurerm_windows_virtual_machine.jump_uks.id
  location              = "uksouth"
  enabled               = true
  daily_recurrence_time = "2300"
  timezone              = "GMT Standard Time"

  notification_settings {
    enabled         = true
    time_in_minutes = 30
    email           = "rjs616@outlook.com"
  }
}

# ── Azure Monitor Agent — modern monitoring ───────────────────
resource "azurerm_virtual_machine_extension" "ama_uks" {
  name                       = "AzureMonitorWindowsAgent"
  virtual_machine_id         = azurerm_windows_virtual_machine.jump_uks.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  depends_on = [azurerm_virtual_machine_extension.aad_login]

  tags = var.tags
}

# ── DCR Association ───────────────────────────────────────────
resource "azurerm_monitor_data_collection_rule_association" "jump_uks" {
  name                    = "dcra-rspltjmpp01"
  target_resource_id      = azurerm_windows_virtual_machine.jump_uks.id
  data_collection_rule_id = data.azurerm_monitor_data_collection_rule.windows.id

  depends_on = [azurerm_virtual_machine_extension.ama_uks]
}

# ── Tailscale — secure remote access ─────────────────────────
resource "azurerm_virtual_machine_extension" "tailscale" {
  name                 = "InstallTailscale"
  virtual_machine_id   = azurerm_windows_virtual_machine.jump_uks.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  protected_settings = jsonencode({
    commandToExecute = "powershell -ExecutionPolicy Unrestricted -Command \"[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://pkgs.tailscale.com/stable/tailscale-setup-latest-amd64.msi' -OutFile 'C:\\tailscale.msi'; Start-Process msiexec.exe -ArgumentList '/i C:\\tailscale.msi /quiet /norestart' -Wait\""
  })

  depends_on = [azurerm_virtual_machine_extension.aad_login]

  tags = var.tags
}