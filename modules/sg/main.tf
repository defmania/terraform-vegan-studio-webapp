locals {
  ip_protocol = "tcp"
}

resource "aws_security_group" "alb_sg" {
  name        = var.alb_sg_name
  description = var.alb_sg_description
  vpc_id      = var.vpc_id

  tags = {
    Name = var.alb_sg_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_sg_http" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.alb_sg_port
  to_port           = var.alb_sg_port
  ip_protocol       = local.ip_protocol
}

resource "aws_vpc_security_group_ingress_rule" "alb_sg_https" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.alb_sg_https_port
  to_port           = var.alb_sg_https_port
  ip_protocol       = local.ip_protocol
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress_alb" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}

resource "aws_security_group" "ec2_sg" {
  name        = var.ec2_sg_name
  description = var.ec2_sg_description
  vpc_id      = var.vpc_id

  tags = {
    Name = var.ec2_sg_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "ec2_sg_http" {
  security_group_id = aws_security_group.ec2_sg.id

  referenced_security_group_id = aws_security_group.alb_sg.id
  from_port                    = var.ec2_sg_port
  to_port                      = var.ec2_sg_port
  ip_protocol                  = local.ip_protocol
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress_ec2" {
  security_group_id = aws_security_group.ec2_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}

resource "aws_security_group" "data_sg" {
  name        = var.data_sg_name
  description = var.data_sg_description
  vpc_id      = var.vpc_id

  tags = {
    Name = var.data_sg_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "data_sg_mysql" {
  security_group_id = aws_security_group.data_sg.id

  referenced_security_group_id = aws_security_group.ec2_sg.id
  from_port                    = var.data_sg_port
  to_port                      = var.data_sg_port
  ip_protocol                  = local.ip_protocol
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress_data" {
  security_group_id = aws_security_group.data_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}
