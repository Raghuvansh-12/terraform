variable "subnet_ids" {
  type = list(string)
}

variable "target_group_arn" {
  type = string
}

variable "alb_sg_id" {
  type = string
}

variable "certificate_arn" {
  default = ""
}

variable "enable_https" {
  type = bool
  default = false
}