resource "aws_instance" "long-operation-api-server" {
  ami           = "ami-0f174d97d7d7a029b"
  instance_type = "t3.micro"
  key_name = "terraform"
  tags = {
    Name = "long-operation-api-server"
  }
  user_data = file("./scripts/apache.sh")
  vpc_security_group_ids = [aws_security_group.long-operation-sg.id]
  # security_groups = [aws_security_group.long-operation-sg.name]
}
