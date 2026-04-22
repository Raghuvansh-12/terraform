variable "key_name" {
  type = string
}

variable "private_key_path" {
  default = "${path.module}/id_rsa"
}