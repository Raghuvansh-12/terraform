resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/app_lambda"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "/aws/apigateway/${aws_apigatewayv2_api.api.name}"
  retention_in_days = 7
}

