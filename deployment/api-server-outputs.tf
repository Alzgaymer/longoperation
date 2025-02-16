output "instance_public_ip" {
  value = jsonencode(aws_instance.long-operation-api-server[*].public_ip)
  description = "The public IP address of the EC2 instance"
}