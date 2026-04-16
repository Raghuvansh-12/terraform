provider "aws" {
    region = "us-east-1"  # Set your desired AWS region
}

# resource "aws_instance" "example" {
#     ami           = "ami-0c3389a4fa5bddaad"  # Specify an appropriate AMI ID
#     instance_type = "t2.micro"
# }

# resource "aws_iam_user" "this" {
#   name = "payments-user-${count.index}"
#   count = 3
# }

resource "aws_iam_user" "that" {
  name = var.users[count.index]
  count = 3
}
variable "users" {
  type = list
  default = ["alice", "bob", "johncorner","james","mrA"]
}