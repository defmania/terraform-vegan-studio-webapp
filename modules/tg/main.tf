resource "aws_lb_target_group" "vs_lg_target_group" {
  name        = var.target_group_name
  port        = var.port
  protocol    = var.protocol
  target_type = var.target_type
  vpc_id      = var.vpc_id

  health_check {
    path                = "/health.html"
    port                = "traffic-port"
    protocol            = var.protocol
    healthy_threshold   = 6
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 5
    matcher             = "200"
  }
}
