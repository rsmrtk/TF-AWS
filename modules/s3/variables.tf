variable "project" {
  description = "Project name used as a prefix for all resources."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}[a-z0-9]$", var.project))
    error_message = "Project must be 3-22 chars, start with a letter, end with a letter or digit, lowercase alphanumeric and hyphens only."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "buckets" {
  description = "Map of S3 bucket configurations to create."
  type = map(object({
    purpose    = string
    versioning = optional(bool, true)
    lifecycle_rules = optional(list(object({
      id                                 = string
      enabled                            = optional(bool, true)
      transition_days                    = optional(number, 30)
      transition_storage_class           = optional(string, "STANDARD_IA")
      expiration_days                    = optional(number, 0)
      noncurrent_version_expiration_days = optional(number, 90)
    })), [])
    force_destroy   = optional(bool, false)
    enable_cors     = optional(bool, false)
    allowed_origins = optional(list(string), [])
  }))
}

variable "kms_key_arn" {
  description = "KMS key ARN for S3 encryption. Falls back to the default AWS managed key when empty."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}
