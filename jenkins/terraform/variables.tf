variable "default_tags" {
  default = {
    application = "bootifulmicropizza"
  }
}

variable "aws_region" {
  type = string
}

variable "aws_account" {
  type = string
}

variable "environment" {
  type = string
}

variable "loadbalancer_arn" {
  type = string
}

variable "loadBalancer_zone" {
  type = string
}

variable "openIdProviderArn" {
  type = string
}

variable "openIdProviderUrl" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "hosted_zone_name" {
  type = string
}

variable "ssm_parameters" {
  type = list
  default = [
    "awsAccessKey",
    "awsSecretKey",
    "github_secret",
    "jenkins-admin-password"
  ]
}