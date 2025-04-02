resource "aws_cloudwatch_log_group" "api_long_operation_logs" {
  name              = "/ecs/api-long-operation"
  retention_in_days = 30
}

resource "aws_iam_policy" "ecs_logging_policy" {
  name        = "ecs-logging-policy"
  description = "Allow ECS tasks to write to CloudWatch logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.api_long_operation_logs.arn}:*"
      }
    ]
  })
}

