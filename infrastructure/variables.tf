variable "default_tags" {
  default = {
    application = "bootifulmicropizza-devops"
  }
}

variable "aws_region" {
  type = string
}

variable "environment" {
  type = string
}

variable "hosted_zone_name" {
  type = string
}

variable "hosted_zone_records_map" {
  type = map(object({
    name = string
    type = string
    ttl = number
    records = list(string)
  }))

  default = {
    www = {
      name = "www.bootifulmicropizza.com"
      type = "CNAME"
      ttl = 300
      records = ["www.prod.bootifulmicropizza.com"]
    },
    api = {
      name = "api.bootifulmicropizza.com"
      type = "CNAME"
      ttl = 300
      records = ["api.prod.bootifulmicropizza.com"]
    }
  }
}