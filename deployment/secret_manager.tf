locals {
  mongo_secrets = {
    USERNAME = {
      key         = "MONGO_USERNAME"
      description = "Mongo atlas database username"
      value       = var.mongo_username
      sensitive   = true
    }
    PASSWORD = {
      key         = "MONGO_PASSWORD"
      description = "Mongo atlas database password"
      value       = var.mongo_password
      sensitive   = true
    }
  }
}

module "mongo_secrets" {
  source  = "terraform-aws-modules/secrets-manager/aws"
  version = "1.3.1"

  for_each = local.mongo_secrets

  name          = each.value.key
  description   = each.value.description
  secret_string = each.value.value
}