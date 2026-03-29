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
  description = "AWS region for the state backend resources."
  type        = string
  default     = "eu-central-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "Must be a valid AWS region identifier."
  }
}

variable "environments" {
  description = "List of environments to create state backends for."
  type        = list(string)
  default     = ["dev", "staging", "prod"]

  validation {
    condition     = length(var.environments) > 0
    error_message = "At least one environment must be specified."
  }
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}
