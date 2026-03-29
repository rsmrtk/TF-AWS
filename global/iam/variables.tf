variable "project" {
  description = "Project name used for resource naming."
  type        = string
  default     = "tfaws"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.project))
    error_message = "Project must start with a letter, contain only lowercase alphanumerics and hyphens, and be 2-21 characters."
  }
}

variable "aws_region" {
  description = "AWS region for IAM resources."
  type        = string
  default     = "eu-central-1"
}

variable "github_org" {
  description = "GitHub organization or user name."
  type        = string
  default     = "rsmrtk"
}

variable "github_repo" {
  description = "GitHub repository name."
  type        = string
  default     = "TF-AWS"
}

variable "state_bucket_arns" {
  description = "Map of environment to state bucket ARNs."
  type        = map(string)
  default     = {}
}

variable "lock_table_arns" {
  description = "Map of environment to lock table ARNs."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}
