terraform {
  backend "s3" {
    bucket         = "tfaws-dev-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "tfaws-dev-terraform-locks"
    encrypt        = true
  }
}
