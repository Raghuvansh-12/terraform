resource "local_file" "index" {
  depends_on = [aws_apigatewayv2_api.api]
  content = templatefile("${path.module}/index.html.tpl", {
    api_url = aws_apigatewayv2_api.api.api_endpoint
  })

  filename = "${path.module}/build/index.html"
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.frontend.id
  key          = "index.html"
  source       = local_file.index.filename
  content_type = "text/html"

  depends_on = [aws_apigatewayv2_api.api]

}