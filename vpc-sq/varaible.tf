variable "vpn_ip" {
    default = "0.0.0.0/0"
    description = "This is a VPN Server Created in AWS"
}

variable "app_port" {
    default = "8080"
}

variable "ssh_port" {
    default = "22"
}

variable "ftp_port" {
    default = "21"
}