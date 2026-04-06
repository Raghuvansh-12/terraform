terraform {
	required_version = ">= 1.3.0"

	required_providers {
		aws = {
			source  = "hashicorp/aws"
			version = "~> 5.0"
		}
	}
}

provider "aws" {
	region = "us-east-1"
}

data "aws_vpc" "default" {
	default = true
}

data "aws_subnets" "default" {
	filter {
		name   = "vpc-id"
		values = [data.aws_vpc.default.id]
	}
}

data "aws_ami" "ubuntu" {
	most_recent = true
	owners      = ["099720109477"] # Canonical

	filter {
		name   = "name"
		values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
	}

	filter {
		name   = "virtualization-type"
		values = ["hvm"]
	}
}

resource "aws_security_group" "nginx_sg" {
	name        = "nginx-ssh-http-sg"
	description = "Allow SSH and HTTP"
	vpc_id      = data.aws_vpc.default.id

	ingress {
		description = "SSH"
		from_port   = 22
		to_port     = 22
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	ingress {
		description = "HTTP"
		from_port   = 80
		to_port     = 80
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = {
		Name = "nginx-ssh-http-sg"
	}
}

resource "aws_instance" "nginx_server" {
	ami                         = data.aws_ami.ubuntu.id
	instance_type               = "t2.micro"
	subnet_id                   = data.aws_subnets.default.ids[0]
	vpc_security_group_ids      = [aws_security_group.nginx_sg.id]
	key_name                    = "your-keypair-name"
	associate_public_ip_address = true

	connection {
		type        = "ssh"
		host        = self.public_ip
		user        = "ubuntu"
		private_key = file("C:/path/to/your-keypair.pem")
		timeout     = "2m"
	}

	provisioner "remote-exec" {
		inline = [
			"sudo apt-get update -y",
			"sudo apt-get install -y nginx",
			"sudo systemctl enable nginx",
			"sudo systemctl start nginx"
		]
	}

	tags = {
		Name = "nginx-provisioner-server"
	}
}

output "nginx_url" {
	value = "http://${aws_instance.nginx_server.public_ip}"
}
