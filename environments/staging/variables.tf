variable "project" {
  description = "Project name."
  type        = string
  default     = "tfaws"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "staging"
}

variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "eu-central-1"
}
