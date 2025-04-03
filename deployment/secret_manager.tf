module "secrets_manager" {
  source = "terraform-aws-modules/secrets-manager/aws"

  name_prefix   = "MONGO_"
  name          = "USERNAME"
  description   = "Mongo atlas database username"
  create_policy = true
  secret_string = var.mongo_username
}

module "secrets_manager" {
  source = "terraform-aws-modules/secrets-manager/aws"

  name_prefix   = "MONGO_"
  name          = "PASSWORD"
  description   = "Mongo atlas database password"
  create_policy = true
  secret_string = var.mongo_password
}
