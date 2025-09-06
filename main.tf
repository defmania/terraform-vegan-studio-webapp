module "networking" {
  source = "./modules/vpc"

  vpc_name       = "vs_vpc"
  vpc_cidr_block = "10.0.0.0/16"
  igw_name       = "vs_igw"
  nat_subnet_key = "public-1"

  public_subnets = {
    "public-1" = { cidr = "10.0.1.0/24", az = "us-east-1a" }
    "public-2" = { cidr = "10.0.2.0/24", az = "us-east-1b" }
  }

  private_subnets = {
    "app-subnet-1a" = { cidr = "10.0.11.0/24", az = "us-east-1a" }
    "db-subnet-1a"  = { cidr = "10.0.12.0/24", az = "us-east-1a" }
    "app-subnet-1b" = { cidr = "10.0.21.0/24", az = "us-east-1b" }
    "db-subnet-1b"  = { cidr = "10.0.22.0/24", az = "us-east-1b" }
  }
}

module "security_groups" {
  source = "./modules/sg"

  alb_sg_name         = "vs-vpc-alb-sg"
  alb_sg_description  = "Allow HTTPS from Internet to ALB"
  alb_sg_port         = 80
  alb_sg_https_port   = 443
  ec2_sg_name         = "vs-vpc-ec2-sg"
  ec2_sg_description  = "Allow HTTP from LB to EC2"
  ec2_sg_port         = 80
  data_sg_name        = "vs-vpc-data-sg"
  data_sg_description = "Allow MySQL from App to Database"
  data_sg_port        = 3306
  vpc_id              = module.networking.vpc_id
}

module "s3" {
  source = "./modules/s3"

  bucket_name = var.bucket_name
}

module "iam" {
  source = "./modules/iam"

  iam_role               = "vs-ec2-master-iam-role"
  iam_role_description   = "Role for allowing EC2 instances to access S3 and SSM"
  iam_policy             = "vs-s3-iam-policy"
  iam_policy_description = "Policy for allowing access to S3 bucket"
  s3_bucket_arn          = module.s3.s3_bucket_arn
}

module "rds" {
  source = "./modules/rds"

  db_subnet_group_name        = "vs-db-subnet-group"
  db_subnet_group_description = "Subnet Group for RDS database"

  db_subnet_ids = [
    for k, id in module.networking.private_subnet_ids : id
    if startswith(k, "db-subnet")
  ]

  #####################################################################################################
  ## for k, id in module.networking.private_subnet_ids - loops through each key-value pair in the map
  ## k - the key (e.g., "db-subnet-1a")
  ## id - the value id of the subnet (e.g., "subnet-12345678910")
  ## : id - the value to include in the resulting list
  ## if startswith(k, "db-subnet") - only include entries where the key starts with "db-subnet"
  #####################################################################################################

  db_identifier        = "recipedb"
  db_name              = "recipedb"
  db_engine            = "mysql"
  db_engine_version    = "8.0"
  db_allocated_storage = 20
  db_instance_class    = "db.t3.micro"
  db_username          = "admin"
  db_password          = var.db_password
  db_security_group    = module.security_groups.data_sg_id
}

module "acm" {
  source = "./modules/certmanager"

  cert_name      = "vs-app-cert"
  domain_name    = var.app_fqdn
  hosted_zone_id = module.route53.hosted_zone_id
}

module "target_group" {
  source = "./modules/tg"

  target_group_name = "vs-app-tg"
  target_type       = "instance"
  port              = 80
  protocol          = "HTTP"
  vpc_id            = module.networking.vpc_id

}

module "route53" {
  source = "./modules/r53"

  hosted_zone_name = var.my_hosted_zone_name
  lb_dns_fqdn      = var.app_fqdn
  lb_dns_name      = module.load_balancer.lb_dns_name
  lb_zone_id       = module.load_balancer.lb_zone_id
}

module "load_balancer" {
  source = "./modules/elb"

  lb_name                          = "vs-app-alb"
  lb_listener_default_action_http  = "redirect"
  lb_listener_default_action_https = "forward"
  lb_listener_port_http            = 80
  lb_listener_port_https           = 443
  lb_listener_protocol_http        = "HTTP"
  lb_listener_protocol_https       = "HTTPS"
  lb_listener_status_code_http     = "HTTP_301"
  lb_security_group                = module.security_groups.alb_sg_id
  lb_target_group_arn              = module.target_group.target_group_arn
  load_balancer_type               = "application"
  subnets                          = [for k, id in module.networking.public_subnet_ids : id]
  is_internal                      = false
  certificate_arn                  = module.acm.certificate_arn
}

module "autoscaling_group" {
  source = "./modules/asg"

  vs_asg_name          = "vs-asg"
  app_security_group   = [module.security_groups.ec2_sg_id]
  key_name             = data.aws_key_pair.my_key.key_name
  instance_type        = "t2.micro"
  enable_autoscaling   = true
  iam_instance_profile = module.iam.aws_instance_profile
  ami_id               = data.aws_ami.amazon_linux_2023.id
  min_size             = 1
  max_size             = 3
  desired_capacity     = 2
  target_group_arns    = [module.target_group.target_group_arn]
  user_data = base64encode(templatefile("${path.module}/templates/userdata.sh.tpl", {
    s3_bucket = var.bucket_name
  }))
  subnets = [
    for k, id in module.networking.private_subnet_ids : id
    if startswith(k, "app-subnet")
  ]
}

data "aws_key_pair" "my_key" {
  key_name = var.key_pair_name
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

locals {
  rendered_db_php = templatefile("${path.module}/templates/db.php.tpl", {
    rds_endpoint = module.rds.database_endpoint,
    db_user      = module.rds.db_user,
    db_password  = var.db_password,
    db_name      = module.rds.database_name
  })
}

resource "local_file" "db_php" {
  content  = local.rendered_db_php
  filename = "${path.module}/files/VeganStudioSourceCode/v5/db.php"
}

resource "null_resource" "upload_folder_to_bucket" {
  provisioner "local-exec" {
    command = "aws s3 sync ${path.module}/files/VeganStudioSourceCode/v5 s3://${var.bucket_name}"
  }

  depends_on = [
    module.s3.bucket_resource,
    local_file.db_php
  ]
}
