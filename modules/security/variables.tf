variable "project" {
  description = "Project name used for resource naming."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,28}[a-z0-9]$", var.project))
    error_message = "Project name must be 3-30 characters, start with a letter, end with a letter or number, and contain only lowercase letters, numbers, and hyphens."
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

variable "vpc_cidr" {
  description = "CIDR block of the VPC."
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
