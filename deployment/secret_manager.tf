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
      Version = "2012-10-17"
      Id      = "mongodb-credentials-policy"
      Statement = [
        {
          Sid      = "AllowEcsTaskToReadSecret"
          Effect   = "Allow"
          Action   = "secretsmanager:GetSecretValue"
          Resource = "*"
        }
      ]
    }
  }
}