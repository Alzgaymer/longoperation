module "mongo_secrets" {
  source  = "terraform-aws-modules/secrets-manager/aws"
  version = "1.3.1"

  name        = "MONGODB_CREDENTIALS"
  description = "MongoDB credentials"
  secret_string = jsonencode({
    username = var.mongo_username,
    password = var.mongo_password
  })
}