variable "project" {
  description = "Project name used in resource naming."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.project))
    error_message = "Project must start with a lowercase letter, contain only lowercase alphanumeric characters and hyphens, and be 2-21 characters long."
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

variable "origin_domain_name" {
  description = "S3 bucket regional domain name or ALB DNS name used as the CloudFront origin."
  type        = string
}

variable "origin_type" {
  description = "Type of origin: s3 for S3 bucket with OAC, alb for Application Load Balancer custom origin."
  type        = string
  default     = "s3"

  validation {
    condition     = contains(["s3", "alb"], var.origin_type)
    error_message = "Origin type must be one of: s3, alb."
  }
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 origin bucket. Used to scope the OAC bucket policy."
  type        = string
  default     = ""
}

variable "aliases" {
  description = "List of CNAMEs (alternate domain names) for the distribution."
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for HTTPS. Must be issued in us-east-1."
  type        = string
  default     = ""
}

variable "price_class" {
  description = "CloudFront price class. Controls which edge locations are used."
  type        = string
  default     = "PriceClass_100"
}

variable "waf_web_acl_arn" {
  description = "ARN of the WAFv2 Web ACL to associate with the distribution."
  type        = string
  default     = ""
}

variable "default_root_object" {
  description = "Object that CloudFront returns when the root URL is requested."
  type        = string
  default     = "index.html"
}

variable "enable_logging" {
  description = "Whether to enable access logging for the distribution."
  type        = bool
  default     = false
}

variable "logging_bucket" {
  description = "S3 bucket domain name for storing CloudFront access logs (e.g. my-bucket.s3.amazonaws.com)."
  type        = string
  default     = ""
}

variable "custom_error_responses" {
  description = "List of custom error response configurations."
  type = list(object({
    error_code            = number
    response_code         = number
    response_page_path    = string
    error_caching_min_ttl = optional(number, 300)
  }))
  default = []
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}
