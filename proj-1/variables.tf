variable "function_name" {
  type = string
  default = "app_lambda"
}

variable "lambda_zip" {
  type = string
  default = "./fn/lambda.zip"
}

variable "runtime" {
    default = "python3.12"
}

variable "handler" {
    default = "fn.handler"
}
