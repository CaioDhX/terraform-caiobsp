terraform {
  required_version = ">=1.11.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.94.1"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = "x"
  secret_key = "x"

  default_tags {
    tags = {
      owner      = "caio-terraform"
      managed-by = "terraform"
    }
  }
}

