# resource "aws_vpc" "bastion" {
#   cidr_block           = "192.168.0.0/16"
#   enable_dns_hostnames = true
# }

resource "aws_vpc" "app" {
  cidr_block           = "172.32.0.0/16"
  enable_dns_hostnames = true
}

# resource "aws_subnet" "bastion_public" {
#   vpc_id            = aws_vpc.bastion.id
#   cidr_block        = "192.168.1.0/24"
#   availability_zone = var.azs[0]
# }


# Subnets in different Availability Zones
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.app.id
  cidr_block        = "172.32.10.0/24"
  availability_zone = "ap-south-1a"

  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1a"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.app.id
  cidr_block        = "172.32.11.0/24"
  availability_zone = "ap-south-1b"

  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2b"
  }
}

resource "aws_subnet" "app_private" {
  count             = 2
  vpc_id            = aws_vpc.app.id
  cidr_block        = cidrsubnet("172.32.0.0/16", 8, count.index + 2)
  availability_zone = var.azs[count.index]
}


# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app.id

  tags = {
    Name = "main-igw"
  }
}

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.app.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "public_subnet_assoc_3" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}



data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_launch_template" "app" {
  name_prefix            = "app-template"
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.asg_sg.id]
  user_data              = base64encode(file("userdata.sh"))

  #   iam_instance_profile {
  #     name = aws_iam_role.ec2.name
  #   }
}


resource "aws_security_group" "asg_sg" {
  name        = "asg-sg"
  description = "Security group for EC2 instances in ASG"
  vpc_id      = aws_vpc.app.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "asg-sg"
  }
}

# After your IGW definition, add:

resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "nat-eip" }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet_1.id
  tags          = { Name = "nat-gw" }
  depends_on    = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.app.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Name = "private-route-table" }
}

resource "aws_route_table_association" "private_rt_assoc" {
  count          = 2
  subnet_id      = aws_subnet.app_private[count.index].id
  route_table_id = aws_route_table.private_rt.id
}
module "asg" {
  source = "../modules/asg"

  name               = "app-asg"
  subnet_ids         = aws_subnet.app_private[*].id
  launch_template_id = aws_launch_template.app.id
  target_group_arns  = [aws_lb_target_group.asg_tg.arn]
  min_size          = 2
  max_size          = 2
  desired_capacity  = 2
  health_check_type = "ELB"

  # optional
  azs = var.azs
}


resource "aws_lb_target_group" "asg_tg" {
  name     = "my-asg-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.app.id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/"
    matcher             = "200"
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.app.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "alb-sg"
  }
}

module "alb" {
  source = "../modules/lb"

  subnet_ids = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]

  alb_sg_id        = aws_security_group.alb_sg.id
  target_group_arn = aws_lb_target_group.asg_tg.arn
}

output "alb_domain" {
  value = module.alb.alb_dns_name
}

data "aws_route53_zone" "this" {
  name = var.domain_name
}

resource "aws_route53_record" "alb_record" {
  zone_id = data.aws_route53_zone.this.id
  name    = "app"
  type    = "CNAME"
  ttl     = 300
  records = [module.alb.alb_dns_name]
  
}