resource "aws_ecr_repository" "oci_registry" {
  name                 = "api_oci_registry"
  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }

  force_delete = true
}