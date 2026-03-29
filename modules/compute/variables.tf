###############################################################################
# Project & Environment
###############################################################################

variable "project" {
  description = "Project name used in resource naming."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.project))
    error_message = "Project must start with a lowercase letter, contain only lowercase alphanumeric characters and hyphens, and be between 2 and 21 characters."
  }
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

###############################################################################
# Networking
###############################################################################

variable "vpc_id" {
  description = "ID of the VPC where resources will be created."
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the ASG instances."
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID to attach to the ALB."
  type        = string
}

variable "app_security_group_id" {
  description = "Security group ID to attach to the application instances."
  type        = string
}

###############################################################################
# Instance Configuration
###############################################################################

variable "instance_type" {
  description = "EC2 instance type for the launch template."
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Custom AMI ID. If empty, the latest Amazon Linux 2023 AMI is used."
  type        = string
  default     = ""
}

variable "key_name" {
  description = "Name of the EC2 key pair for SSH access. Leave empty to disable SSH key."
  type        = string
  default     = ""
}

variable "instance_profile_name" {
  description = "Name of the IAM instance profile to attach to instances."
  type        = string
  default     = ""
}

###############################################################################
# Auto Scaling
###############################################################################

variable "min_size" {
  description = "Minimum number of instances in the ASG."
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in the ASG."
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired number of instances in the ASG."
  type        = number
  default     = 1
}

###############################################################################
# Health Check
###############################################################################

variable "health_check_path" {
  description = "Path for the ALB target group health check."
  type        = string
  default     = "/health"
}

variable "health_check_port" {
  description = "Port for the ALB target group health check."
  type        = number
  default     = 80
}

###############################################################################
# HTTPS / TLS
###############################################################################

variable "enable_https" {
  description = "Whether to create an HTTPS listener on the ALB."
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate for the HTTPS listener."
  type        = string
  default     = ""
}

###############################################################################
# Encryption
###############################################################################

variable "kms_key_arn" {
  description = "ARN of the KMS key for EBS volume encryption. Uses the default AWS managed key when empty."
  type        = string
  default     = ""
}

###############################################################################
# User Data
###############################################################################

variable "user_data" {
  description = "User data script to run on instance launch."
  type        = string
  default     = ""
}

###############################################################################
# Tags
###############################################################################

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}
