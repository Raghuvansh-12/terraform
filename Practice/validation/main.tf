variable "db_password" {
  type = string

  validation {
    condition = length(var.db_password) >= 12
    error_message = "Length of Database Password must be equal to or greater than 12 characters"
  }
}

check "website_checker" {
   data "http" "example" {
      url = "https://google.com"
   }

   assert {
     condition = data.http.example.status_code == 200
     error_message = "Website is not running. Please check"
   }
}

resource "local_file" "foo" {
  content  = "Hi"
  filename = "${path.module}/foo.txt"
}

