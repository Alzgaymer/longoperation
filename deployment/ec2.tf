resource "aws_instance" "hello_world" {
  ami           = "ami-0f174d97d7d7a029b"
  instance_type = "t3.micro"
  key_name = "terraform"
  tags = {
    Name = "hello_world"
  }
  security_groups = [aws_security_group.ssh.name]
}

resource "aws_security_group" "ssh" {
  name = "hello_world_ssh"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}