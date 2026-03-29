# Security Module

Manages core security resources for the AWS infrastructure including KMS encryption keys, VPC security groups, WAF v2 web ACLs, and ACM certificates.

## Resources Created

- **KMS** -- General-purpose encryption key with automatic rotation and service-level access policies (CloudWatch Logs, S3, RDS, SNS, SQS).
- **Security Groups** -- ALB, application, database, and bastion security groups with least-privilege ingress rules.
- **WAF v2** -- (Optional) Regional web ACL with AWS managed rule groups for common threats, known bad inputs, and SQL injection.
- **ACM** -- (Optional) TLS certificate with DNS validation.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
