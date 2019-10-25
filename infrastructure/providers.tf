provider "aws" {
  region  = var.aws_region
  allowed_account_ids = [
    "337036170088"
  ]
}
