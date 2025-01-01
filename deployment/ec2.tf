resource "aws_instance" "hello_world" {
  ami           = "ami-02df5cb5ad97983ba"
  instance_type = "t3.micro"
  key_name = "terraform"
}