variable "project" {
  description = "Project name used for resource naming."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,28}[a-z0-9]$", var.project))
    error_message = "Project name must be 3-30 characters, start with a letter, end with a letter or digit, and contain only lowercase letters, digits, and hyphens."
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
  description = "ID of the VPC where ECS resources will be deployed."
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS service networking."
  type        = list(string)
}

variable "app_security_group_id" {
  description = "Security group ID to attach to ECS services."
  type        = string
}

variable "services" {
  description = "Map of ECS service configurations keyed by service name."
  type = map(object({
    container_image       = string
    container_port        = number
    cpu                   = optional(number, 256)
    memory                = optional(number, 512)
    desired_count         = optional(number, 1)
    health_check_path     = optional(string, "/health")
    environment_variables = optional(map(string), {})
    secrets               = optional(map(string), {})
    target_group_arn      = optional(string, "")
  }))
  default = {}
}

variable "execution_role_arn" {
  description = "ARN of the IAM role that ECS uses to pull images and publish logs."
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the IAM role that the running task assumes."
  type        = string
}

variable "enable_execute_command" {
  description = "Whether to enable ECS Exec for interactive debugging."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for encrypting CloudWatch log groups. Leave empty to use AWS-managed encryption."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}
