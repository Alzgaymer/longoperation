# Create S3 Full Access Policy
resource "aws_iam_policy" "s3_policy" {
  name        = "s3-policy"
  description = "Policy for allowing all S3 Actions"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${var.oapi-s3-bucket}/*"
        }
    ]
}
EOF

}

# Create API Gateway Role
resource "aws_iam_role" "s3_api_gateway_role" {
  name = "s3-api-gateway-role"

  # Create Trust Policy for API Gateway
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach S3 Access Policy to the API Gateway Role
resource "aws_iam_role_policy_attachment" "s3_policy_attach" {
  role       = aws_iam_role.s3_api_gateway_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_api_gateway_rest_api" "long-op" {
  name = "Long Operation API"

  body = templatefile(var.oapi-file, {
    role_arn            = aws_iam_role.s3_api_gateway_role.arn,
    region              = var.region,
    bucket_name         = var.oapi-s3-bucket,
    fargate_service_url = aws_lb.fargate_nlb.dns_name,
    vpc_link_id         = aws_api_gateway_vpc_link.fargate.id
  })
}

resource "aws_api_gateway_deployment" "S3APIDeployment" {
  rest_api_id = aws_api_gateway_rest_api.long-op.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.long-op.body,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.S3APIDeployment.id
  rest_api_id   = aws_api_gateway_rest_api.long-op.id
  stage_name    = "dev"
}