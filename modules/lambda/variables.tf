variable "project" {
  description = "Project name used for resource naming"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,28}[a-z0-9]$", var.project))
    error_message = "Project name must be 3-30 characters, start with a letter, end with a letter or number, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "functions" {
  description = "Map of Lambda function configurations"
  type = map(object({
    description           = optional(string, "")
    runtime               = string
    handler               = string
    filename              = optional(string, "")
    s3_bucket             = optional(string, "")
    s3_key                = optional(string, "")
    memory_size           = optional(number, 128)
    timeout               = optional(number, 30)
    environment_variables = optional(map(string), {})
    vpc_config = optional(object({
      subnet_ids         = list(string)
      security_group_ids = list(string)
    }), null)
    reserved_concurrent_executions = optional(number, -1)
    layers                         = optional(list(string), [])
  }))
  default = {}
}

variable "lambda_role_arn" {
  description = "IAM role ARN for Lambda function execution"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for encrypting Lambda environment variables"
  type        = string
  default     = ""
}

variable "enable_api_gateway" {
  description = "Whether to create an API Gateway HTTP API for the Lambda functions"
  type        = bool
  default     = false
}

variable "api_gateway_name" {
  description = "Name for the API Gateway. If empty, defaults to name_prefix-api"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
