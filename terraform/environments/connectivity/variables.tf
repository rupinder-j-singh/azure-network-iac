# ============================================================
# Connectivity Environment — Variables
# ============================================================

variable "subscription_id" {
  description = "Connectivity subscription ID"
  type        = string
}

variable "entity" {
  description = "Entity code e.g. rs"
  type        = string
  default     = "rs"
}

variable "environment" {
  description = "Environment code"
  type        = string
  default     = "p"
}

variable "tags" {
  description = "Default tags applied to all resources"
  type        = map(string)
  default     = {}
}
variable "management_subscription_id" {
  description = "Management subscription ID for cross-subscription data sources"
  type        = string
  default     = "f3c0dff2-e481-44f1-9581-8047d8148dc4"
}

variable "vm_admin_password" {
  description = "Admin password for jump server VM"
  type        = string
  sensitive   = true
}