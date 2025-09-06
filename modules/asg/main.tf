resource "aws_launch_template" "vs_lt" {
  name_prefix            = "${var.vs_asg_name}-lt-"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = var.app_security_group
  key_name               = var.key_name

  user_data = base64encode(var.user_data)

  lifecycle {
    create_before_destroy = true
  }

  iam_instance_profile {
    name = var.iam_instance_profile
  }
}

resource "aws_autoscaling_group" "vs_asg" {
  name                = var.vs_asg_name
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = var.subnets
  health_check_type   = "ELB"
  target_group_arns   = var.target_group_arns
  force_delete        = true

  launch_template {
    id      = aws_launch_template.vs_lt.id
    version = "$Latest"

  }

  tag {
    key                 = "Name"
    value               = var.vs_asg_name
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  count = var.enable_autoscaling ? 1 : 0

  scheduled_action_name  = "${var.vs_asg_name}-scale-out-during-business-hours"
  min_size               = 2
  max_size               = 3
  desired_capacity       = 3
  recurrence             = "0 6 * * *"
  autoscaling_group_name = aws_autoscaling_group.vs_asg.name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  count = var.enable_autoscaling ? 1 : 0

  scheduled_action_name  = "${var.vs_asg_name}-scale-in-at-night"
  min_size               = 2
  max_size               = 3
  desired_capacity       = 2
  recurrence             = "0 14 * * *"
  autoscaling_group_name = aws_autoscaling_group.vs_asg.name

}
