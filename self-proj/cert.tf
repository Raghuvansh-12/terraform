resource "aws_acm_certificate" "app" {
  domain_name       = "app.${var.domain_name}" # app.raghuvansh.online
  validation_method = "DNS"

  tags = {
    Name = "app-cert"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# DNS validation
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.app.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.this.id
}

resource "aws_acm_certificate_validation" "app" {
  certificate_arn = aws_acm_certificate.app.arn
  depends_on      = [aws_route53_record.cert_validation]
}
