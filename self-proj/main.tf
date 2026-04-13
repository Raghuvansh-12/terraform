resource "aws_vpc" "bastion" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_vpc" "app" {
  cidr_block           = "172.32.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_subnet" "bastion_public" {
  vpc_id            = aws_vpc.bastion.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = var.azs[0]
}

resource "aws_subnet" "app_public" {
  vpc_id            = aws_vpc.app.id
  cidr_block        = "172.32.1.0/24"
  availability_zone = var.azs[0]
}

resource "aws_subnet" "app_private" {
  count             = 2
  vpc_id            = aws_vpc.app.id
  cidr_block        = cidrsubnet("172.32.0.0/16", 8, count.index + 2)
  availability_zone = var.azs[count.index]
}


resource "aws_launch_template" "app" {
  name_prefix   = "app-template"
  image_id      = "var.launch_template_ami"
  instance_type = "t3.micro"

  user_data = base64encode(file("userdata.sh"))

  iam_instance_profile {
    name = aws_iam_role.ec2.name
  }
}

module "asg" {
  source = "../modules/asg"

  name                = "app-asg"
  subnet_ids          = aws_subnet.app_private[*].id
  launch_template_id  = aws_launch_template.app.id

  min_size            = 2
  max_size            = 4
  desired_capacity    = 2

  target_group_arns   = [aws_lb_target_group.tg.arn]

  # optional
  azs = var.azs
}
