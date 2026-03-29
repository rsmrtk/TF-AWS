variable "project" {
  description = "Project name used for resource naming."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}[a-z0-9]$", var.project))
    error_message = "Project must be 3-22 chars, start with a letter, end with a letter or digit, only lowercase alphanumeric and hyphens."
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
  description = "ID of the VPC where the EKS cluster will be deployed."
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the EKS cluster and node groups."
  type        = list(string)
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.30"

  validation {
    condition     = can(regex("^\\d+\\.\\d+$", var.cluster_version))
    error_message = "Cluster version must match the X.Y format (e.g., 1.30)."
  }
}

variable "node_groups" {
  description = "Map of managed node group configurations."
  type = map(object({
    instance_types = list(string)
    capacity_type  = optional(string, "ON_DEMAND")
    min_size       = number
    max_size       = number
    desired_size   = number
    disk_size      = optional(number, 50)
    labels         = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  }))
}

variable "cluster_addons" {
  description = "Map of EKS cluster addons to enable."
  type = map(object({
    version = optional(string, null)
  }))
  default = {
    vpc-cni            = { version = null }
    coredns            = { version = null }
    kube-proxy         = { version = null }
    aws-ebs-csi-driver = { version = null }
  }
}

variable "enable_cluster_encryption" {
  description = "Whether to enable envelope encryption for Kubernetes secrets."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for cluster encryption. Required when enable_cluster_encryption is true."
  type        = string
  default     = ""
}

# Defaults to false -- production clusters should not expose the API publicly.
# Override in dev/staging if you need kubectl access without a VPN.
variable "cluster_endpoint_public_access" {
  description = "Whether the EKS cluster API server endpoint is publicly accessible."
  type        = bool
  default     = false
}

variable "cluster_endpoint_private_access" {
  description = "Whether the EKS cluster API server endpoint is privately accessible."
  type        = bool
  default     = true
}

variable "cluster_log_types" {
  description = "List of EKS control plane logging types to enable."
  type        = list(string)
  default     = ["api", "audit", "authenticator"]
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}
