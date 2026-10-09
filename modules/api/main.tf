# 3. HTTP API v2
resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.name_prefix}-http-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["POST", "OPTIONS"]
    allow_headers = ["content-type", "authorization"]
    max_age       = 300
  }
}

# 6. Stage $default
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = 5000
    throttling_rate_limit  = 10000
  }
}

# 4. Integracion con Lambda
resource "aws_apigatewayv2_integration" "lambda_upload" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.upload_invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# 5. Ruta POST /upload
resource "aws_apigatewayv2_route" "post_upload" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /upload"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_upload.id}"
}
