resource "aws_security_group" "bastion" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # open SSH
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami           = var.ami
  instance_type = "t2.micro"
  subnet_id     = var.public_subnet
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.bastion.id]
}

