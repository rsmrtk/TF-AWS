# Compute Module

Terraform module that manages AWS compute resources including an Application Load Balancer (ALB), EC2 Launch Template, and Auto Scaling Group (ASG).

## Resources Created

- **ALB** -- Public-facing application load balancer with HTTP/HTTPS listeners
- **Target Group** -- Health-checked target group for application instances
- **Launch Template** -- EC2 launch template with IMDSv2, encrypted EBS, and configurable user data
- **Auto Scaling Group** -- Mixed instances policy ASG with rolling instance refresh
- **Scaling Policy** -- Target tracking policy on average CPU utilisation (70%)
- **S3 Bucket** -- ALB access logs bucket (disabled by default)

## Usage

```hcl
module "compute" {
  source = "./modules/compute"

  project     = "myapp"
  environment = "prod"

  vpc_id             = module.networking.vpc_id
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids

  alb_security_group_id = module.security.alb_sg_id
  app_security_group_id = module.security.app_sg_id

  instance_type = "t3.small"
  min_size      = 2
  max_size      = 6
  desired_capacity = 2

  enable_https    = true
  certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/abc-123"

  tags = {
    Team = "platform"
  }
}
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
