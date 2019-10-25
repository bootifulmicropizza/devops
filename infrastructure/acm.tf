module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> v2.0"

  domain_name = var.hosted_zone_name
  zone_id     = aws_route53_zone.zone.zone_id

  subject_alternative_names = [
    "*.${var.hosted_zone_name}",
    var.hosted_zone_name,
  ]
}

output "certificate_arn" {
  value = module.acm.this_acm_certificate_arn
}
