module "networking" {
  source = "../../modules/networking"

  project     = var.project
  environment = var.environment
  vpc_cidr    = "10.2.0.0/16"
  azs         = local.azs

  # prod runs a NAT per AZ for resilience
  single_nat_gateway      = false
  enable_vpc_endpoints    = true
  enable_flow_logs        = true
  flow_log_retention_days = 90

  tags = local.common_tags
}

module "security" {
  source = "../../modules/security"

  project     = var.project
  environment = var.environment
  vpc_id      = module.networking.vpc_id
  enable_waf  = true
  waf_mode    = "block"

  tags = local.common_tags
}

module "iam" {
  source = "../../modules/iam"

  project     = var.project
  environment = var.environment
  kms_key_arn = module.security.kms_key_arn

  tags = local.common_tags
}

module "s3" {
  source = "../../modules/s3"

  project     = var.project
  environment = var.environment
  kms_key_arn = module.security.kms_key_arn

  buckets = {
    assets = {
      purpose    = "Application static assets"
      versioning = true
      lifecycle_rules = [
        {
          id              = "transition-to-ia"
          transition_days = 30
        },
        {
          id                                 = "cleanup-old-versions"
          noncurrent_version_expiration_days = 90
        }
      ]
    }
    logs = {
      purpose    = "Application and access logs"
      versioning = true
      lifecycle_rules = [
        {
          id              = "transition-to-ia"
          transition_days = 30
        },
        {
          id              = "expire-old-logs"
          transition_days = 60
          expiration_days = 180
        }
      ]
    }
    backups = {
      purpose    = "Database and application backups"
      versioning = true
      lifecycle_rules = [
        {
          id                       = "transition-to-ia"
          transition_days          = 30
          transition_storage_class = "STANDARD_IA"
        },
        {
          id              = "expire-old-backups"
          expiration_days = 365
        }
      ]
    }
  }

  tags = local.common_tags
}

module "ecr" {
  source = "../../modules/ecr"

  project     = var.project
  environment = var.environment
  kms_key_arn = module.security.kms_key_arn

  repositories = {
    app = {
      scan_on_push    = true
      max_image_count = 50
    }
  }

  tags = local.common_tags
}

module "compute" {
  source = "../../modules/compute"

  project               = var.project
  environment           = var.environment
  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  private_subnet_ids    = module.networking.private_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  app_security_group_id = module.security.app_security_group_id
  instance_type         = "m5.large"
  instance_profile_name = module.iam.ec2_instance_profile_name
  min_size              = 2
  max_size              = 6
  desired_capacity      = 3
  certificate_arn       = "" # TODO: replace with ACM certificate ARN
  kms_key_arn           = module.security.kms_key_arn

  tags = local.common_tags
}

module "eks" {
  source = "../../modules/eks"

  project            = var.project
  environment        = var.environment
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  kms_key_arn        = module.security.kms_key_arn

  node_groups = {
    general = {
      instance_types = ["m5.xlarge"]
      min_size       = 3
      max_size       = 6
      desired_size   = 3
      disk_size      = 100
    }
  }

  # lock down the control plane -- operators connect via VPN or SSM
  cluster_endpoint_public_access  = false
  cluster_endpoint_private_access = true

  tags = local.common_tags
}

module "ecs" {
  source = "../../modules/ecs"

  project               = var.project
  environment           = var.environment
  private_subnet_ids    = module.networking.private_subnet_ids
  app_security_group_id = module.security.app_security_group_id
  execution_role_arn    = module.iam.ecs_execution_role_arn
  task_role_arn         = module.iam.ecs_task_role_arn
  kms_key_arn           = module.security.kms_key_arn

  # ECS Exec disabled in prod -- operators use SSM instead
  enable_ecs_exec = false

  tags = local.common_tags
}

module "rds" {
  source = "../../modules/rds"

  project                      = var.project
  environment                  = var.environment
  data_subnet_ids              = module.networking.data_subnet_ids
  db_security_group_id         = module.security.db_security_group_id
  engine                       = "postgres"
  engine_version               = "16.4"
  instance_class               = "db.r5.large"
  allocated_storage            = 100
  max_allocated_storage        = 500
  multi_az                     = true
  backup_retention_period      = 35
  deletion_protection          = true
  skip_final_snapshot          = false
  performance_insights_enabled = true
  kms_key_arn                  = module.security.kms_key_arn

  tags = local.common_tags
}

module "monitoring" {
  source = "../../modules/monitoring"

  project     = var.project
  environment = var.environment

  # REQUIRED: set actual email addresses before deploying
  alarm_email_endpoints = var.alarm_emails

  kms_key_arn = module.security.kms_key_arn

  alarms = {
    high-cpu = {
      description         = "Average CPU utilization exceeds 80% for 5 minutes"
      namespace           = "AWS/EC2"
      metric_name         = "CPUUtilization"
      comparison_operator = "GreaterThanThreshold"
      threshold           = 80
      evaluation_periods  = 2
      period              = 300
      statistic           = "Average"
      treat_missing_data  = "missing"
    }
    rds-connections = {
      description         = "RDS database connections exceed 100"
      namespace           = "AWS/RDS"
      metric_name         = "DatabaseConnections"
      comparison_operator = "GreaterThanThreshold"
      threshold           = 100
      evaluation_periods  = 2
      period              = 300
      statistic           = "Average"
      treat_missing_data  = "missing"
    }
  }

  tags = local.common_tags
}

# CloudFront -- uncomment when the S3 assets bucket or ALB origin is ready.
#
# module "cloudfront" {
#   source = "../../modules/cloudfront"
#
#   project            = var.project
#   environment        = var.environment
#   origin_domain_name = module.s3.bucket_regional_domain_names["assets"]
#   origin_type        = "s3"
#   aliases            = []                         # e.g. ["cdn.example.com"]
#   acm_certificate_arn = ""                        # Must be in us-east-1
#   price_class        = "PriceClass_200"
#   waf_web_acl_arn    = module.security.waf_acl_arn
#   enable_logging     = true
#   logging_bucket     = ""                         # e.g. module.s3.bucket_domain_names["logs"]
#
#   tags = local.common_tags
# }

# Route53 -- uncomment when the domain and hosted zone are ready.
#
# module "route53" {
#   source = "../../modules/route53"
#
#   project     = var.project
#   environment = var.environment
#   create_zone = false
#   zone_id     = ""                                # Existing hosted zone ID
#
#   records = {}
#   health_checks = {}
#
#   tags = local.common_tags
# }
