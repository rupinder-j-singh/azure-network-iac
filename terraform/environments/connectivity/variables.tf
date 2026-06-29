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