provider "aws" {
  region = "us-east-1"
}

data "aws_ec2_instance_type" "myec2" {
  instance_type = "t3.large"
}

resource "aws_instance" "myec2" {
  ami           = "ami-0c3389a4fa5bddaad"
  instance_type = "t2.micro"

  tags = {
    Name = "HelloEartdsafasdh"
  }

  # lifecycle {
  #   #   create_before_destroy = true
  #   #   prevent_destroy = true
  #   ignore_changes = [tags, instance_type]

  # }

  lifecycle {

    precondition {
      condition     = data.aws_ec2_instance_type.myec2.free_tier_eligible
      error_message = "Instance Type is not part of free tier"
    }

    postcondition {
      condition     = self.public_dns != ""
      error_message = "Public IPV4 or DNS is mandatory for this server"
    }
  }
}

# resource "aws_instance" "example" {
#   ami           = "ami-0c3389a4fa5bddaad"
#   instance_type = "t2.micro"
#   depends_on    = [aws_s3_bucket.example]
# }

# resource "aws_s3_bucket" "example" {
#   bucket = "kplabs-demo-s3-007"
# }