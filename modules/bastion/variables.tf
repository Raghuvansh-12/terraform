variable "vpc_id" {
  type = string
}

variable "public_subnet" {
  type = string
}

variable "key_name" {
  type = string
}

variable "ami" {
  description = "AMI ID for bastion"
  type        = string
}