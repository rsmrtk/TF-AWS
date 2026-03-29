variable "project" {
  description = "Project name used as a prefix for all resources."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{2,21}$", var.project))
    error_message = "Project must be 2-21 characters, lowercase alphanumeric and hyphens only."
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
  description = "ARN of the KMS key for S3 encryption. If empty, uses aws:kms with the default AWS managed key."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}
