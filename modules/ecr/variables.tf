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

variable "repositories" {
  description = "Map of ECR repositories to create. The key is the service/repository name."
  type = map(object({
    image_tag_mutability = optional(string, "IMMUTABLE")
    scan_on_push         = optional(bool, true)
    max_image_count      = optional(number, 30)
    force_delete         = optional(bool, false)
  }))
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for ECR encryption. If empty, AES256 encryption is used."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}
