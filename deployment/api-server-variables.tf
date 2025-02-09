variable "region" {
  type = string
  default = "eu-north-1"
}

variable "ssh-port" {
  type = number
  default = 22
}


variable "http-port" {
  type = number
  default = 80
}

variable "white-list" {
  type = list(string)
  default = [
    "212.23.203.92/32"
  ]
  sensitive = true
}

variable "api-server" {
  type = object({
    ami       = string
    instance  = string
    key-name  = string
    tags      = map(string)
  })

  default = {
    "ami": "ami-0f174d97d7d7a029b"
    "instance": "t3.micro"
    "key-name":"terraform"
    "tags": {
      "Name": "long-operation-api-server"
    }
  }
}