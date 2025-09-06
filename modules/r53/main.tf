data "aws_route53_zone" "hosted_zone" {
  name         = var.hosted_zone_name
  private_zone = false
}

resource "aws_route53_record" "lb_dns_record" {
  zone_id = data.aws_route53_zone.hosted_zone.id
  name    = var.lb_dns_fqdn
  type    = "A"

  alias {
    name                   = var.lb_dns_name
    zone_id                = var.lb_zone_id
    evaluate_target_health = true
  }
}
