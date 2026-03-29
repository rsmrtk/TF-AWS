variable "project" {
  description = "Project name for resource naming."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}[a-z0-9]$", var.project))
    error_message = "Must be 3-22 chars, start with a letter, end alphanumeric, lowercase + hyphens only."
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

variable "create_zone" {
  description = "Whether to create a new Route53 hosted zone. Set true to create, false to use an existing zone via zone_id."
  type        = bool
  default     = false
}

variable "zone_name" {
  description = "Domain name for the hosted zone (e.g. example.com). Required when create_zone is true."
  type        = string
  default     = ""
}

variable "zone_id" {
  description = "ID of an existing Route53 hosted zone. Used when create_zone is false."
  type        = string
  default     = ""
}

variable "records" {
  description = "Map of DNS records to create. Set health_check_key to link a record to a health check defined in var.health_checks."
  type = map(object({
    type             = string
    ttl              = optional(number, 300)
    records          = optional(list(string), [])
    health_check_key = optional(string, null)
    alias = optional(object({
      name                   = string
      zone_id                = string
      evaluate_target_health = optional(bool, true)
    }), null)
  }))
  default = {}
}

variable "health_checks" {
  description = "Map of Route53 health checks to create. Each key becomes part of the health check name."
  type = map(object({
    fqdn              = string
    port              = optional(number, 443)
    type              = optional(string, "HTTPS")
    resource_path     = optional(string, "/health")
    failure_threshold = optional(number, 3)
    request_interval  = optional(number, 30)
  }))
  default = {}
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}
