module "networking" {
  source = "../../modules/networking"

  project            = var.project
  environment        = var.environment
  vpc_cidr           = "10.1.0.0/16"
  azs                = local.azs
  single_nat_gateway = true

  enable_vpc_endpoints    = true
  enable_flow_logs        = true
  flow_log_retention_days = 30

  tags = local.common_tags
}

module "security" {
  source = "../../modules/security"

  project     = var.project
  environment = var.environment
  vpc_id      = module.networking.vpc_id
  enable_waf  = true
  waf_mode    = "count"

  tags = local.common_tags
}

# No Lambda module in this environment, so skip the Lambda role.
module "iam" {
  source = "../../modules/iam"

  project     = var.project
  environment = var.environment

  create_ec2_role           = true
  create_ecs_task_role      = true
  create_ecs_execution_role = true
  create_lambda_role        = false

  kms_key_arn    = module.security.kms_key_arn
  s3_bucket_arns = values(module.s3.bucket_arns)

  tags = local.common_tags
}

module "s3" {
  source = "../../modules/s3"

  project     = var.project
  environment = var.environment
  kms_key_arn = module.security.kms_key_arn

  buckets = {
    assets = {
      purpose    = "Static assets"
      versioning = true
      lifecycle_rules = [
        {
          id                                 = "transition-to-ia"
          enabled                            = true
          transition_days                    = 30
          transition_storage_class           = "STANDARD_IA"
          noncurrent_version_expiration_days = 90
        }
      ]
    }
    logs = {
      purpose    = "Application and access logs"
      versioning = false
      lifecycle_rules = [
        {
          id              = "expire-old-logs"
          enabled         = true
          expiration_days = 90
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
      image_tag_mutability = "IMMUTABLE"
      scan_on_push         = true
      max_image_count      = 20
    }
    worker = {
      image_tag_mutability = "IMMUTABLE"
      scan_on_push         = true
      max_image_count      = 20
    }
  }

  tags = local.common_tags
}

module "compute" {
  source = "../../modules/compute"

  project     = var.project
  environment = var.environment

  vpc_id             = module.networking.vpc_id
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids

  alb_security_group_id = module.security.alb_security_group_id
  app_security_group_id = module.security.app_security_group_id

  instance_type         = "t3.small"
  instance_profile_name = module.iam.ec2_instance_profile_name

  min_size         = 1
  max_size         = 3
  desired_capacity = 2

  kms_key_arn = module.security.kms_key_arn

  tags = local.common_tags
}

module "eks" {
  source = "../../modules/eks"

  project     = var.project
  environment = var.environment

  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids

  cluster_version = "1.30"

  node_groups = {
    general = {
      instance_types = ["t3.large"]
      capacity_type  = "ON_DEMAND"
      min_size       = 2
      max_size       = 4
      desired_size   = 2
      disk_size      = 50
    }
  }

  enable_cluster_encryption       = true
  kms_key_arn                     = module.security.kms_key_arn
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  tags = local.common_tags
}

module "ecs" {
  source = "../../modules/ecs"

  project     = var.project
  environment = var.environment

  private_subnet_ids = module.networking.private_subnet_ids

  app_security_group_id = module.security.app_security_group_id

  execution_role_arn = module.iam.ecs_execution_role_arn
  task_role_arn      = module.iam.ecs_task_role_arn

  enable_ecs_exec = true
  kms_key_arn     = module.security.kms_key_arn

  tags = local.common_tags
}

module "rds" {
  source = "../../modules/rds"

  project     = var.project
  environment = var.environment

  data_subnet_ids      = module.networking.data_subnet_ids
  db_security_group_id = module.security.db_security_group_id

  engine         = "postgres"
  engine_version = "16.4"
  instance_class = "db.t3.medium"

  allocated_storage     = 20
  max_allocated_storage = 100

  multi_az                = false
  backup_retention_period = 14
  deletion_protection     = true
  skip_final_snapshot     = false

  kms_key_arn                  = module.security.kms_key_arn
  performance_insights_enabled = true
  monitoring_interval          = 60

  tags = local.common_tags
}

module "monitoring" {
  source = "../../modules/monitoring"

  project               = var.project
  environment           = var.environment
  alarm_email_endpoints = []
  kms_key_arn           = module.security.kms_key_arn

  tags = local.common_tags
}
