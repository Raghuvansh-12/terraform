data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

module "key_pair" {
  source           = "../modules/key-gen"
  key_name         = "docker-practice-key"
  private_key_path = "docker-practice-key.pem"
}

resource "aws_instance" "example" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  key_name = module.key_pair.key_name

  tags = {
    Name = "docker-practice"
  }
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file(module.key_pair.private_key_path)
    timeout     = "2m"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install docker.io -y",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "usermod -aG docker ubuntu",
      "docker run -d -p 80:80 --name nginx nginx"
    ]
  }
}
