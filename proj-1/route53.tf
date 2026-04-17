data "aws_route53_zone" "selected" {
  name = var.domain_name
}

# resource "aws_route53_record" "s3_alias" {
#   zone_id = data.aws_route53_zone.selected.zone_id # Example Zone ID
#   name    = data.aws_route53_zone.selected.name
#   type    = "A"

#   alias {
#     # The domain name depends on the region, e.g., s3-website.us-east-1.amazonaws.com
#     name                   = aws_s3_bucket_website_configuration.frontend.website_domain
#     zone_id                = aws_s3_bucket.frontend.hosted_zone_id
#     evaluate_target_health = false
#   }
# }

resource "aws_route53_record" "frontend" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.frontend.domain_name
    zone_id                = aws_cloudfront_distribution.frontend.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "api.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_apigatewayv2_domain_name.api_domain.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.api_domain.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}