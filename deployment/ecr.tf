resource "aws_ecr_repository" "api-long_operation" {
  name                 = "api-long_operation"
  image_tag_mutability = "IMMUTABLE"

  tags = {
    Name       = "api-long_operation"
    GithubRepo = "https://github.com/Alzgaymer/longoperation"
  }
  encryption_configuration {
    encryption_type = "AES256"
  }

  force_delete = true
}