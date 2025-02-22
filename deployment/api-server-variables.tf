variable "region" {
  type    = string
  default = "eu-north-1"
}

variable "white-list" {
  type = list(string)
  default = [
    "212.23.203.92/32"
  ]
  sensitive = true

}