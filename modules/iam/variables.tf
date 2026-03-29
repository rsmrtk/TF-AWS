variable "project" {
  description = "Project name used for resource naming."
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

variable "create_ec2_role" {
  description = "Whether to create the EC2 IAM role and instance profile."
  type        = bool
  default     = true
}

variable "create_ecs_task_role" {
  description = "Whether to create the ECS task IAM role."
  type        = bool
  default     = true
}

variable "create_ecs_execution_role" {
  description = "Whether to create the ECS execution IAM role."
  type        = bool
  default     = true
}

variable "create_lambda_role" {
  description = "Whether to create the Lambda execution IAM role."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for encryption permissions. Leave empty to skip KMS permissions."
  type        = string
  default     = ""
}

variable "s3_bucket_arns" {
  description = "List of S3 bucket ARNs the roles can access. Leave empty to skip S3 permissions."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}
