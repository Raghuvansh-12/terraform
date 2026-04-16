terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "terraform-backends-471112801232-us-east-1-an"
    key    = "remote/demo.tfstate"
    region = "us-east-1"
    use_lockfile = true
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_user" "dev" {
  name = "kplabs-user-01"
}

resource "aws_security_group" "prod" {
  name        = "terraform-firewalls"
}