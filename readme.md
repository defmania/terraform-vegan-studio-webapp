# 🚀 Terraform Infrastructure Project

This repository defines a modular, production-grade infrastructure setup using Terraform. It provisions a complete AWS environment including networking, compute, storage, security, and application deployment components.

---

## 📁 Terraform Project Structure

### Root Directory

- `main.tf` – Calls all modules and data sources
- `outputs.tf` – Root-level outputs
- `terraform.tf` – Backend configuration and settings
- `variables.tf` – Root-level input variables

### Templates

- `templates/db.php.tpl` – PHP template for database connection
- `templates/userdata.sh.tpl` – Shell script template for EC2 user data

### Modules

#### `modules/asg/` – Auto Scaling Group

- `main.tf` – Launch template, ASG, and scheduling
- `outputs.tf` – ASG name, Launch Template ID
- `variables.tf`

#### `modules/certmanager/` – TLS Certificate Management

- `main.tf` – ACM certificate and DNS validation
- `outputs.tf` – Certificate ARN
- `variables.tf`

#### `modules/elb/` – Application Load Balancer

- `main.tf` – ALB, HTTP and HTTPS listeners
- `outputs.tf` – ALB ARN, DNS name, Zone ID
- `variables.tf`

#### `modules/iam/` – IAM Roles and Policies

- `main.tf` – IAM role, policies, attachments, instance profile
- `outputs.tf` – Role ARN, Instance Profile name
- `variables.tf`

#### `modules/route53/` – DNS Records

- `main.tf` – Hosted zone lookup and DNS A record
- `outputs.tf` – Hosted Zone ID
- `variables.tf`

#### `modules/rds/` – Relational Database

- `main.tf` – DB subnet group and RDS instance
- `outputs.tf` – DB endpoint, name, username
- `variables.tf`

#### `modules/s3/` – S3 Bucket

- `main.tf` – Bucket creation and versioning
- `outputs.tf` – Bucket ARN, ID, resource reference
- `variables.tf`

#### `modules/sg/` – Security Groups

- `main.tf` – SGs for ALB, EC2, RDS with ingress/egress rules
- `outputs.tf` – SG IDs for ALB, EC2, RDS
- `variables.tf`

#### `modules/tg/` – Target Group

- `main.tf` – Target group for ALB
- `outputs.tf` – Target Group ARN, name
- `variables.tf`

#### `modules/vpc/` – Networking

- `main.tf` – VPC, subnets, route tables, NAT gateway, IGW
- `outputs.tf` – VPC ID, ARN, subnet IDs
- `variables.tf`

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
