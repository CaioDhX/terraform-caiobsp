variable "regiao" {
  description = "Região dos recursos"
  type        = string
  default     = "us-east-1a"
}



variable "ami_id" {
  type        = string
  description = "valor da AMI"
  default     = "ami-00a929b66ed6e0de6" # amazon linux
}
