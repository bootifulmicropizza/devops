variable "default_tags" {
  default = {
    application = "bootifulmicropizza"
  }
}

variable "aws_region" {
  type = string
}

variable "environment" {
  type = string
}

variable "loadbalancer_arn" {
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
    "argocdPassword"
  ]
}