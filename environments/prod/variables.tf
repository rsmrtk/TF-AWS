variable "project" {
  description = "Project name."
  type        = string
  default     = "tfaws"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "prod"
}

variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "eu-central-1"
}

variable "alarm_emails" {
  description = "Email addresses for CloudWatch alarm notifications."
  type        = list(string)
  default     = []
}
