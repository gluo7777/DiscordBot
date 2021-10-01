resource "aws_route53_record" "discord" {
  name    = var.subdomain
  zone_id = local.zone
  type    = "A"
  alias {
    name                   = aws_api_gateway_domain_name.discord.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.discord.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate" "discord" {
  domain_name       = "${var.subdomain}.${data.aws_route53_zone.domain.name}"
  validation_method = "DNS"
  tags              = var.tags
  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_route53_record" "discord-certificate" {
  for_each = {
    for dvo in aws_acm_certificate.discord.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = local.zone
}

resource "aws_acm_certificate_validation" "discord" {
  certificate_arn         = aws_acm_certificate.discord.arn
  validation_record_fqdns = [for record in aws_route53_record.discord-certificate : record.fqdn]
}
