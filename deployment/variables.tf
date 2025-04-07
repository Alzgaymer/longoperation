variable "region" {
  type    = string
  default = "eu-north-1"
}

variable "white-list" {
  type = list(string)
  default = [
    "212.23.203.92/32",
    "104.28.129.60/32"
  ]
  sensitive = true
}

variable "oapi-file" {
  type    = string
  default = "../longoperation-api.yaml"
}

variable "oapi-s3-bucket" {
  type    = string
  default = "oapi-spec"
}

variable "mongo_password" {
  description = "Mongo Atlas database password"
  type        = string
  sensitive   = true
}

variable "mongo_username" {
  description = "Mongo Atlas database mongo_username"
  type        = string
  sensitive   = true
}

variable "container_port" {
  description = "Container port for the Fargate service"
  type        = number
  default     = 8080
}