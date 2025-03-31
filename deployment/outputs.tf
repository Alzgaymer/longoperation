output "gateway_url" {
  value       = aws_api_gateway_stage.dev.invoke_url
  description = "The URL of the API Gateway deployment"
}

output "ecr_repository_url" {
  value = aws_ecr_repository.api-long_operation_registry.repository_url
}