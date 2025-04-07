resource "aws_security_group" "long-operation-sg" {
  name   = "long-operation-sg"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "allow_http" {
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  type              = "ingress"
  security_group_id = aws_security_group.long-operation-sg.id
  cidr_blocks       = var.white-list
}

resource "aws_security_group_rule" "allow_ssh" {
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  type              = "ingress"
  security_group_id = aws_security_group.long-operation-sg.id
  cidr_blocks       = var.white-list
}

resource "aws_security_group_rule" "allow_all" {
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  type              = "egress"
  security_group_id = aws_security_group.long-operation-sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_healthcheck" {
  from_port         = var.container_port
  to_port           = var.container_port
  protocol          = "tcp"
  type              = "ingress"
  security_group_id = aws_security_group.long-operation-sg.id
  cidr_blocks       = ["10.0.0.0/16"]
}