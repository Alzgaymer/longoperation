module "mongo_secrets" {
  source  = "terraform-aws-modules/secrets-manager/aws"
  version = "1.3.1"

  name        = "MONGODB_CREDENTIALS"
  description = "MongoDB credentials"
  secret_string = jsonencode({
    username = var.mongo_username,
    password = var.mongo_password
  })

  force_overwrite_replica_secret = true
  recovery_window_in_days        = 0

  create_policy       = true
  block_public_policy = true
  policy_statements = {
    esc_tasks_read = {
      sid    = "AllowEcsTaskToReadSecret"
      effect = "Allow"
      principals = [{
        type        = "AWS"
        identifiers = [aws_iam_role.ecs_task_execution_role.arn]
      }]
      actions   = ["secretsmanager:GetSecretValue"]
      resources = ["*"]
    }
  }
}