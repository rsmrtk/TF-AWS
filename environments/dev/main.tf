# -----------------------------------------------------------------------------
# Networking
# -----------------------------------------------------------------------------
module "networking" {
  source = "../../modules/networking"

  project                 = var.project
  environment             = var.environment
  vpc_cidr                = "10.0.0.0/16"
  azs                     = local.azs
  single_nat_gateway      = true
  enable_vpc_endpoints    = true
  enable_flow_logs        = true
  flow_log_retention_days = 14

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Security
# -----------------------------------------------------------------------------
module "security" {
  source = "../../modules/security"

  project     = var.project
  environment = var.environment
  vpc_id      = module.networking.vpc_id
  vpc_cidr    = module.networking.vpc_cidr
  enable_waf  = false

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# IAM
# -----------------------------------------------------------------------------
module "iam" {
  source = "../../modules/iam"

  project     = var.project
  environment = var.environment
  kms_key_arn = module.security.kms_key_arn

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# S3
# -----------------------------------------------------------------------------
module "s3" {
  source = "../../modules/s3"

  project     = var.project
  environment = var.environment
  kms_key_arn = module.security.kms_key_arn

  buckets = {
    assets = {
      purpose    = "Application static assets"
      versioning = true
    }
    logs = {
      purpose    = "Application and access logs"
      versioning = false
      lifecycle_rules = [
        {
          id              = "expire-old-logs"
          transition_days = 30
          expiration_days = 90
        }
      ]
    }
  }

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# ECR
# -----------------------------------------------------------------------------
module "ecr" {
  source = "../../modules/ecr"

  project     = var.project
  environment = var.environment
  kms_key_arn = module.security.kms_key_arn

  repositories = {
    app = {
      scan_on_push    = true
      max_image_count = 10
    }
  }

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Compute (ALB + ASG)
# -----------------------------------------------------------------------------
module "compute" {
  source = "../../modules/compute"

  project               = var.project
  environment           = var.environment
  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  private_subnet_ids    = module.networking.private_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  app_security_group_id = module.security.app_security_group_id
  instance_type         = "t3.micro"
  instance_profile_name = module.iam.ec2_instance_profile_name
  min_size              = 1
  max_size              = 2
  desired_capacity      = 1
  kms_key_arn           = module.security.kms_key_arn

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# EKS
# -----------------------------------------------------------------------------
module "eks" {
  source = "../../modules/eks"

  project            = var.project
  environment        = var.environment
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  kms_key_arn        = module.security.kms_key_arn

  node_groups = {
    general = {
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 2
      desired_size   = 1
      disk_size      = 30
    }
  }

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# ECS
# -----------------------------------------------------------------------------
module "ecs" {
  source = "../../modules/ecs"

  project               = var.project
  environment           = var.environment
  vpc_id                = module.networking.vpc_id
  private_subnet_ids    = module.networking.private_subnet_ids
  app_security_group_id = module.security.app_security_group_id
  execution_role_arn    = module.iam.ecs_execution_role_arn
  task_role_arn         = module.iam.ecs_task_role_arn
  kms_key_arn           = module.security.kms_key_arn

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# RDS
# -----------------------------------------------------------------------------
module "rds" {
  source = "../../modules/rds"

  project                 = var.project
  environment             = var.environment
  vpc_id                  = module.networking.vpc_id
  data_subnet_ids         = module.networking.data_subnet_ids
  db_security_group_id    = module.security.db_security_group_id
  engine                  = "postgres"
  engine_version          = "16.4"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  multi_az                = false
  backup_retention_period = 7
  deletion_protection     = false
  skip_final_snapshot     = true
  kms_key_arn             = module.security.kms_key_arn

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Monitoring
# -----------------------------------------------------------------------------
module "monitoring" {
  source = "../../modules/monitoring"

  project     = var.project
  environment = var.environment
  kms_key_arn = module.security.kms_key_arn

  tags = local.common_tags
}
