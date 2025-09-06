# 🚀 Terraform Infrastructure Project

This repository defines a modular, production-grade infrastructure setup using Terraform. It provisions a complete AWS environment including networking, compute, storage, security, and application deployment components.

---

## 📁 Project Structure

terraform/
├── modules/
│   ├── asg/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── certmanager/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── elb/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── iam/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── route53/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── rds/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── s3/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── sg/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── tg/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── vpc/
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── templates/
│   ├── db.php.tpl
│   └── userdata.sh.tpl
├── main.tf
├── outputs.tf
├── terraform.tf
└── variables.tf
---

## 🧱 Module Breakdown

### `/asg`
- **Resources**: `aws_launch_template`, `aws_autoscaling_group`, `aws_autoscaling_schedule`
- **Outputs**: ASG name, Launch Template ID

### `/certmanager`
- **Resources**: `aws_acm_certificate`, `aws_route53_record`
- **Outputs**: Certificate ARN

### `/elb`
- **Resources**: `aws_lb`, `aws_lb_listener` (HTTP & HTTPS)
- **Outputs**: ALB ARN, DNS name, Zone ID

### `/iam`
- **Resources**: IAM role, policies, attachments, instance profile
- **Outputs**: Role ARN, Instance Profile name

### `/route53`
- **Resources**: `aws_route53_zone` (data), `aws_route53_record`
- **Outputs**: Hosted Zone ID

### `/rds`
- **Resources**: `aws_db_subnet_group`, `aws_db_instance`
- **Outputs**: DB endpoint, name, username

### `/s3`
- **Resources**: `aws_s3_bucket`, `aws_s3_bucket_versioning`
- **Outputs**: Bucket ARN, ID, resource reference for `null_resource` upload

### `/sg`
- **Resources**: Security groups for ALB, EC2, RDS; ingress/egress rules
- **Outputs**: SG IDs for ALB, EC2, RDS

### `/tg`
- **Resources**: `aws_lb_target_group`
- **Outputs**: Target Group ARN, name

### `/vpc`
- **Resources**: VPC, public/private subnets, route tables, NAT gateway, IGW
- **Outputs**: VPC ID, ARN, subnet IDs

---

## 🧩 Template Usage

### `db.php.tpl`
Used to generate a PHP config file with database credentials. Rendered via `templatefile()` and written locally using `local_file`, then uploaded to S3.

### `userdata.sh.tpl`
Used as a startup script for EC2 instances, fetched via launch template user data.

---

## 🔧 Root Module Highlights

- Fetches latest Amazon Linux 2023 AMI via `data "aws_ami"`
- Retrieves existing EC2 key pair via `data "aws_key_pair"`
- Renders `db.php` using local variables and template
- Uploads rendered config to S3 using `null_resource`

---

## 🛡️ Security & Access

- IAM roles grant EC2 access to S3 and SSM
- Security groups enforce least privilege between ALB, EC2, and RDS
- TLS certificate managed via ACM and validated through Route 53

---

## 📌 Notes

- All modules are reusable and parameterized via `variables.tf`
- Outputs are exposed for cross-module referencing
- Designed for high availability across multiple AZs

---

## 🧠 Next Steps

- Add CI/CD integration for automated Terraform deployment
- Implement Secrets Manager for secure DB credential injection
- Extend ASG with rolling updates or blue/green deployment logic

---

## 🧑‍💻 Author

Bogdan — Infrastructure Architect & Terraform Enthusiast  
📍 Bucharest, Romania

---
