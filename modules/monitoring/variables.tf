variable "project" {
  description = "Project name used as a prefix for all resources."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.project))
    error_message = "Project must start with a lowercase letter, contain only lowercase alphanumeric characters and hyphens, and be 2-21 characters long."
  }
}

variable "environment" {
  description = "Deployment environment (dev, staging, or prod)."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "alarm_email_endpoints" {
  description = "List of email addresses to receive SNS alarm notifications."
  type        = list(string)
  default     = []
}

variable "alarms" {
  description = "Map of CloudWatch alarm configurations."
  type = map(object({
    description         = optional(string, "")
    namespace           = string
    metric_name         = string
    comparison_operator = string
    threshold           = number
    evaluation_periods  = optional(number, 2)
    period              = optional(number, 300)
    statistic           = optional(string, "Average")
    dimensions          = optional(map(string), {})
    treat_missing_data  = optional(string, "missing")
  }))
  default = {}
}

variable "dashboard_widgets" {
  description = "List of CloudWatch dashboard widget configurations."
  type = list(object({
    type        = string
    title       = string
    namespace   = string
    metric_name = string
    dimensions  = optional(map(string), {})
    stat        = optional(string, "Average")
    period      = optional(number, 300)
  }))
  default = []
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for SNS topic encryption. Leave empty to skip encryption."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}
