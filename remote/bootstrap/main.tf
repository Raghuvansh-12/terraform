
provider "aws" {
  region = var.region
}

variable "region" {
  type    = string
  default = "us-east-1"
}


data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "terraform_state" {
  bucket = format("terraform-backends-%s-%s-an", data.aws_caller_identity.current.account_id, var.region)
  bucket_namespace = "account-regional"
  force_destroy = true
  tags = {
    Name = "terrafrom-backends"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}