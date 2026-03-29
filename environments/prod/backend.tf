terraform {
  backend "s3" {
    bucket         = "tfaws-prod-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "tfaws-prod-terraform-locks"
    encrypt        = true
  }
}
