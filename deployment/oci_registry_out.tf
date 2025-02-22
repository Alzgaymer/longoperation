output "oci_registry" {
  description = "OCI Registry URL"
  value = aws_ecr_repository.oci_registry.repository_url
}