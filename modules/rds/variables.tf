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

variable "data_subnet_ids" {
  description = "List of subnet IDs for the DB subnet group."
  type        = list(string)
}

variable "db_security_group_id" {
  description = "Security group ID to attach to the RDS instance."
  type        = string
}

variable "engine" {
  description = "Database engine type."
  type        = string
  default     = "postgres"

  validation {
    condition     = contains(["postgres", "mysql"], var.engine)
    error_message = "Engine must be postgres or mysql. For Aurora, use a dedicated aurora module."
  }
}

variable "engine_version" {
  description = "Database engine version."
  type        = string
  default     = "16.4"
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GiB for the RDS instance."
  type        = number
  default     = 20

  validation {
    condition     = var.allocated_storage >= 20
    error_message = "Allocated storage must be at least 20 GiB."
  }
}

variable "max_allocated_storage" {
  description = "Maximum storage in GiB for autoscaling."
  type        = number
  default     = 100
}

variable "database_name" {
  description = "Name of the default database to create."
  type        = string
  default     = "app"
}

variable "master_username" {
  description = "Master username for the database."
  type        = string
  default     = "dbadmin"
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment for high availability."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups."
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_period >= 1 && var.backup_retention_period <= 35
    error_message = "Backup retention period must be between 1 and 35 days."
  }
}

variable "deletion_protection" {
  description = "Enable deletion protection on the RDS instance."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when destroying the RDS instance. Leave false for prod."
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for storage and performance insights encryption. Uses AWS managed key if empty."
  type        = string
  default     = ""
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights for the RDS instance."
  type        = bool
  default     = true
}

variable "monitoring_interval" {
  description = "Enhanced monitoring interval in seconds. Set to 0 to disable."
  type        = number
  default     = 60

  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval)
    error_message = "Monitoring interval must be one of: 0, 1, 5, 10, 15, 30, 60."
  }
}

variable "parameter_group_family" {
  description = "DB parameter group family override. Auto-derived from engine+version if empty."
  type        = string
  default     = ""
}

variable "parameters" {
  description = "List of DB parameter group parameters."
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}
