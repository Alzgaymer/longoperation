resource "aws_instance" "long-operation-api-server" {
  ami                    = var.api-server.ami
  instance_type          = var.api-server.instance
  key_name               = var.api-server.key-name
  tags                   = var.api-server.tags
  user_data              = file("./scripts/apache.sh")
  vpc_security_group_ids = [aws_security_group.long-operation-sg.id]
}
