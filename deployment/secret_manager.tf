locals {
  mongo_secrets = {
    USERNAME = {
      description = "Mongo atlas database username"
      value       = var.mongo_username
      sensitive   = true
    }
    PASSWORD = {
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

  name_prefix   = "MONGO_"
  name          = each.key
  description   = each.value.description
  create_policy = true
  secret_string = each.value.value
}