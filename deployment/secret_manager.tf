module "mongo_secrets" {
  source  = "terraform-aws-modules/secrets-manager/aws"
  version = "1.3.1"

  name        = "MONGODB_CREDENTIALS"
  description = "MongoDB credentials"
  secret_string = jsonencode({
    username = var.mongo_username,
    password = var.mongo_password
  })

  create_policy       = true
  block_public_policy = true
  policy_statements = {
    ecs_tasks = {
      Sid    = "AllowEcsTaskToReadSecret"
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Resource = module.mongo_secrets.secret_arn
    }
  }
}