terraform {
  backend "s3" {
    bucket         = "tfaws-staging-terraform-state"
    key            = "staging/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "tfaws-staging-terraform-locks"
    encrypt        = true
  }
}
