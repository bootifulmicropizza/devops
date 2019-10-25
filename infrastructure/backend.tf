terraform {
  backend "s3" {
    bucket         = "bootifulmicropizza-devops-tf-state"
    key            = "devops/infrastructure/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "bootifulmicropizza-tf-state-locks"
    encrypt        = true
  }
}
