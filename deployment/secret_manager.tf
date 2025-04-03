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
      sid = "AllowEcsTaskToReadSecret"
      principals = [{
        type        = "AWS"
        identifiers = [aws_ecs_cluster.api-long-operation-cluster.arn]
      }]
      actions   = "secretsmanager:GetSecretValue"
      resources = "*"
    }
  }
}