variable "project" {
  description = "Project name used for resource naming."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}[a-z0-9]$", var.project))
    error_message = "Project must be 3-22 chars, start with a letter, end with a letter or digit, lowercase alphanumeric and hyphens only."
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

variable "functions" {
  description = "Map of Lambda function configurations."
  type = map(object({
    description           = optional(string, "")
    runtime               = string
    handler               = string
    filename              = optional(string, "")
    s3_bucket             = optional(string, "")
    s3_key                = optional(string, "")
    s3_object_version     = optional(string, "")
    source_code_hash      = optional(string, "")
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
  description = "IAM role ARN for Lambda execution."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for encrypting Lambda environment variables."
  type        = string
  default     = ""
}

variable "enable_dlq" {
  description = "Create a dead-letter queue (SNS topic) for failed invocations."
  type        = bool
  default     = true
}

variable "enable_api_gateway" {
  description = "Create an API Gateway HTTP API for the Lambda functions."
  type        = bool
  default     = false
}

variable "api_gateway_name" {
  description = "Name for the API Gateway. Defaults to name_prefix-api when empty."
  type        = string
  default     = ""
}

variable "api_authorization_type" {
  description = "Authorization type for API Gateway routes."
  type        = string
  default     = "NONE"

  validation {
    condition     = contains(["NONE", "JWT", "AWS_IAM"], var.api_authorization_type)
    error_message = "Must be NONE, JWT, or AWS_IAM."
  }
}

variable "cors_allowed_origins" {
  description = "Allowed origins for CORS. Use specific origins in production."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}
