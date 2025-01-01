resource "aws_instance" "hello_world" {
  ami           = "ami-09085dcbbfc5e181e"
  instance_type = "t2.micro"
  key_name = "terraform"
}