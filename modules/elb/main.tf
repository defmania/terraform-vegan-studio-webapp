resource "aws_lb" "vs_lb" {
  name               = var.lb_name
  internal           = var.is_internal
  load_balancer_type = var.load_balancer_type
  security_groups    = [var.lb_security_group]
  subnets            = var.subnets

  enable_deletion_protection = false

  tags = {
    Name = var.lb_name
  }

}

resource "aws_lb_listener" "vs_lb_listener_http" {
  load_balancer_arn = aws_lb.vs_lb.arn
  port              = var.lb_listener_port_http
  protocol          = var.lb_listener_protocol_http

  default_action {
    type = var.lb_listener_default_action_http
    redirect {
      port        = var.lb_listener_port_https
      protocol    = var.lb_listener_protocol_https
      status_code = var.lb_listener_status_code_http
    }
  }
}

resource "aws_lb_listener" "vs_lb_listener_https" {
  load_balancer_arn = aws_lb.vs_lb.arn
  port              = var.lb_listener_port_https
  protocol          = var.lb_listener_protocol_https
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2019-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = var.lb_listener_default_action_https
    target_group_arn = var.lb_target_group_arn
  }
}
