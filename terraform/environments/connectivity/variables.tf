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
variable "pipeline_sp_object_id" {
  description = "Object ID of the network IAC pipeline service principal"
  type        = string
  default     = "e1b7218d-80e9-4da3-8604-7cf9f0c2e0a4"
}