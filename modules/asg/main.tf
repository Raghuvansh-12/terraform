data "aws_availability_zones" "available" {}

locals {
  selected_azs = length(var.azs) > 0 ? var.azs : slice(data.aws_availability_zones.available.names, 0, 2)
}

resource "aws_autoscaling_group" "this" {
  name = var.name

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = var.launch_template_id
    version = "$Latest"
  }

  target_group_arns = var.target_group_arns

  health_check_type         = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }
}