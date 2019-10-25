data "aws_route53_zone" "zone" {
  name         = "${var.hosted_zone_name}."
  private_zone = false
}

resource "aws_route53_record" "argocd" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = var.domain_name
  type    = "CNAME"
  ttl     = "300"
  records = [var.loadbalancer_arn]
}
