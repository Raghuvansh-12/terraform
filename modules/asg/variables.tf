variable "name" {
  type = string
}

variable "region" {
  type    = string
  default = null
}

variable "azs" {
  type    = list(string)
  default = []
}

variable "subnet_ids" {
  type = list(string)
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 4
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "launch_template_id" {
  type = string
}

variable "target_group_arns" {
  type    = list(string)
  default = []
}