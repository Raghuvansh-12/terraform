data "aws_ami" "ecs" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  owners = ["amazon"]
}

resource "aws_iam_role" "ec2_role" {
  name = "ecs-ec2-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}


resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ecs-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_launch_template" "asg_ecs" {
  name_prefix   = "ecs-"
  image_id      = data.aws_ami.ecs.id
  instance_type = "t3.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(<<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.main.name} >> /etc/ecs/ecs.config
EOF
  )
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


module "asg" {
  source = "../../modules/asg"

  name               = "app-asg"
  subnet_ids         = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  launch_template_id = aws_launch_template.asg_ecs.id
  target_group_arns  = [aws_lb_target_group.asg_tg.arn]
  min_size           = 2
  max_size           = 2
  desired_capacity   = 2
  health_check_type  = "ELB"

  # optional
  azs = var.azs
}
