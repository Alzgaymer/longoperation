terraform {
  required_version = ">= 1.0.0" # Ensure that the Terraform version is 1.0.0 or higher

  required_providers {
    aws = {
      source  = "hashicorp/aws" # Specify the source of the AWS provider
      version = "~> 5.86.0"     # Use a version of the AWS provider that is compatible with version
    }
  }

  backend "s3" {
    encrypt = true
    bucket = "alzgaymer-terraform"
    key    = "api/long-operation/terraform.tfstate"
    region = "eu-north-1"
  }
}

provider "aws" {
  region = var.region
}