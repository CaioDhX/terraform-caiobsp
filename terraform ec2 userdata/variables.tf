variable "regiao" {
  type        = string
  description = "Regiao"
  default     = "us-east-1"
}

variable "subnet-regiao" {
  type        = string
  description = "Regiao Subnet"
  default     = "us-east-1a"
}

variable "ami_id" {
  type        = string
  description = "valor da AMI"
  default     = "ami-00a929b66ed6e0de6" # amazon linux
}
