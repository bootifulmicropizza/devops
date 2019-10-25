resource "aws_route53_zone" "zone" {
  name = var.hosted_zone_name
}

resource "aws_route53_record" "records" {
  for_each = var.hosted_zone_records_map

  zone_id = aws_route53_zone.zone.zone_id
  name    = each.value["name"]
  type    = each.value["type"]
  ttl     = each.value["ttl"]
  records = each.value["records"]
}
