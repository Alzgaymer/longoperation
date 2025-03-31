resource "aws_api_gateway_rest_api" "long-op-gateway" {
  name        = "long-op-gateway"
  description = "API Gateway for Long Operation"
  body        = file(var.oapi-file)
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "long-op-gateway-deployment" {
  rest_api_id = aws_api_gateway_rest_api.long-op-gateway.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.long-op-gateway.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "long-op-gateway-stage" {
  deployment_id = aws_api_gateway_deployment.long-op-gateway-deployment.id
  rest_api_id   = aws_api_gateway_rest_api.long-op-gateway.id
  stage_name    = "dev"
}

resource "aws_api_gateway_resource" "long-op-oapi-swagger" {
  rest_api_id = aws_api_gateway_rest_api.long-op-gateway.id
  parent_id   = aws_api_gateway_rest_api.long-op-gateway.root_resource_id
  path_part   = "oapi"
}

resource "aws_api_gateway_method" "long-op-oapi-swagger" {
  resource_id   = aws_api_gateway_resource.long-op-oapi-swagger.id
  rest_api_id   = aws_api_gateway_rest_api.long-op-gateway.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "long-op-oapi-s3" {
  http_method             = aws_api_gateway_method.long-op-oapi-swagger.http_method
  resource_id             = aws_api_gateway_resource.long-op-oapi-swagger.id
  rest_api_id             = aws_api_gateway_rest_api.long-op-gateway.id
  type                    = "AWS"
  integration_http_method = "GET"

  uri         = "arn:aws:apigateway:${var.region}:s3:path/${var.oapi-s3-bucket}/index.html"
  credentials = aws_iam_role_policy.api_gateway_s3_policy.id
}

resource "aws_api_gateway_method_response" "s3_response_200" {
  rest_api_id = aws_api_gateway_rest_api.long-op-gateway.id
  resource_id = aws_api_gateway_resource.long-op-oapi-swagger.id
  http_method = aws_api_gateway_method.long-op-oapi-swagger.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Content-Type" = true
  }
}

resource "aws_api_gateway_integration_response" "s3_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.long-op-gateway.id
  resource_id = aws_api_gateway_resource.long-op-oapi-swagger.id
  http_method = aws_api_gateway_method.long-op-oapi-swagger.http_method
  status_code = aws_api_gateway_method_response.s3_response_200.status_code

  response_parameters = {
    "method.response.header.Content-Type" = "integration.response.header.Content-Type"
  }
}

// This IAM role allows API Gateway to access the S3 bucket
resource "aws_iam_role" "api_gateway_s3_role" {
  name = "api_gateway_s3_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "api_gateway_s3_policy" {
  name = "api_gateway_s3_policy"
  role = aws_iam_role.api_gateway_s3_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "s3:GetObject"
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${var.oapi-s3-bucket}/*"
      }
    ]
  })
}