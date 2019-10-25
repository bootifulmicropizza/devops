provider "aws" {
  region  = var.aws_region
  allowed_account_ids = [
    "201655463889",
    "255580044180",
    "337036170088"
  ]
}
