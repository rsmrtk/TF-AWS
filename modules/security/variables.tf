variable "project" {
  description = "Project name used for resource naming."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}[a-z0-9]$", var.project))
    error_message = "Project must be 3-22 lowercase alphanumeric characters or hyphens, starting with a letter."
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

variable "vpc_id" {
  description = "ID of the VPC where security groups will be created."
  type        = string
}

variable "enable_waf" {
  description = "Whether to create WAF v2 web ACL."
  type        = bool
  default     = false
}

variable "waf_mode" {
  description = "WAF rule action mode. 'count' only counts matches; 'block' actively blocks requests."
  type        = string
  default     = "count"

  validation {
    condition     = contains(["count", "block"], var.waf_mode)
    error_message = "WAF mode must be one of: count, block."
  }
}

variable "waf_log_retention_days" {
  description = "Retention period for WAF CloudWatch logs. Only used when enable_waf is true."
  type        = number
  default     = 30

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.waf_log_retention_days)
    error_message = "Retention days must be a valid CloudWatch Logs retention value."
  }
}

variable "domain_name" {
  description = "Primary domain name for the ACM certificate. Leave empty to skip certificate creation."
  type        = string
  default     = ""
}

variable "subject_alternative_names" {
  description = "Additional domain names (SANs) for the ACM certificate."
  type        = list(string)
  default     = []
}

variable "kms_key_deletion_window" {
  description = "Number of days before a KMS key is deleted after destruction. Must be between 7 and 30."
  type        = number
  default     = 30

  validation {
    condition     = var.kms_key_deletion_window >= 7 && var.kms_key_deletion_window <= 30
    error_message = "KMS key deletion window must be between 7 and 30 days."
  }
}

variable "app_ports" {
  description = "List of ports the application listens on, used for ALB-to-app security group ingress rules."
  type        = list(number)
  default     = [8080]
}

variable "db_port" {
  description = "Database port for the DB security group ingress rule."
  type        = number
  default     = 5432
}

variable "bastion_allowed_cidrs" {
  description = "List of CIDR blocks allowed SSH access to the bastion host. Empty list means no ingress rule is created."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}
