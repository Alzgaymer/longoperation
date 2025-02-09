resource "aws_security_group" "long-operation-sg" {
  name = "long-operation-sg"

  // allow ssh
  ingress {
    from_port   = var.ssh-port
    to_port     = var.ssh-port
    protocol    = "tcp"
    cidr_blocks = var.white-list
  }

  // allow http
  ingress {
    from_port   = var.http-port
    to_port     = var.http-port
    protocol    = "tcp"
    cidr_blocks = var.white-list
  }

  // allow access all the internet from container
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}