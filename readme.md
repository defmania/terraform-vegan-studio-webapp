Terraform Project File Structure:

/terraform:
    - /modules
        ○ /asg
            § main.tf
            § outputs.tf
            § variables.tf
        ○ /certmanager
            § main.tf
            § outputs.tf
            § variables.tf
        ○ /elb
            § main.tf
            § outputs.tf
            § variables.tf
        ○ /iam
            § main.tf
            § outputs.tf
            § variables.tf
        ○ /route53
            § main.tf
            § outputs.tf
            § variables.tf
        ○ /rds
            § main.tf
            § outputs.tf
            § variables.tf
        ○ /s3
            § main.tf
            § outputs.tf
            § variables.tf
        ○ /sg
            § main.tf
            § outputs.tf
            § variables.tf
        ○ /tg
            § main.tf
            § outputs.tf
            § variables.tf
        ○ vpc
            § main.tf
            § outputs.tf
            § variables.tf
    - templates
        ○ db.php.tpl
        ○ userdata.sh.tpl
    - main.tf
    - outputs.tf
    - terraform.tf
    - variables.tf


Terraform Project detailed resources creation within the file structure:

/terraform:
    - /modules
        ○ /asg
            § main.tf
                □ aws_launch_template (launch template used by the autoscaling group which contains instances data)
                □ aws_autoscalling_group (autoscaling group used to manage instances)
                □ aws_autoscalling_schedule (automatic scheduling for the instances)
            § outputs.tf
                □ asg_name -> aws_autoscalling_group.<logical_name>.name
                □ launch_template_od -> aws_launch_template.<logical_name>.id
            § variables.tf
        ○ /certmanager
            § main.tf
                □ aws_acm_certificate (TLS certificate used by the load balancer)
                □ aws_route53_record (for validation)
            § outputs.tf
                □ certificate_arn -> aws_acm_certificate.<logical_name>.arn
            § variables.tf
        ○ /elb
            § main.tf
                □ aws_lb (ALB used for accessing the application from the outside world)
                □ aws_lb_listener (http) (HTTP listener to redirect http requests to https)
                □ aws_lb_listener (https) (HTTPS listener to direct requests to the target group)
            § outputs.tf
                □ lb_arn -> aws_lb.<logical_name>.arn
                □ lb_dns_name -> aws_lb.<logical_name>.dns_name (this is required by the route53 module to create the A record)
                □ lb_zone_id -> aws.lb.<logical_name>.zone_id (this is required by the route53 module to create the A record)
            § variables.tf
        ○ /iam
            § main.tf
                □ aws_iam_role (role used by the instance profile) (sts:AssumeRole for EC2)
                □ aws_iam_policy (policy to allow access to S3)
                □ aws_iam_policy (policy to allow SSM access)
                □ aws_iam_role_policy_attachment (policy attachment to the role used by instance profile for the S3 allow policy)
                □ aws_iam_role_policy_attachment (policy attachment to the role used by instance profile for the SSM allow policy)
                □ aws_iam_instance_profile (creates an Instance Profile to be attached to the EC2 instances of the Launch Template referencing the role created above)
            § outputs.tf
                □ aws_role_arn -> aws_iam_role.<logical_name>.arn
                □ aws_instance_profile -> aws_iam_instance_profile.<logical_name>.name
            § variables.tf
        ○ /route53
            § main.tf
                □ data resource for aws_route53_zone (used to retrieve the zone_id for the given zone name)
                □ aws_route53_record (DNS A record for the Load Balancer)
            § outputs.tf
                □ hosted_zone_id -> data.aws_route53_zone.<logical_name>.zone_id (in case it is required by other modules)
            § variables.tf
        ○ /rds
            § main.tf
                □ aws_db_subnet_group (subnet group to use for the RDS database)
                □ aws_db_instance (DB instance resource)
            § outputs.tf
                □ database_endpoint -> aws_db_instance.<logical_name>.endpoint (Endpoint to connect to RDS)
                □ database_name -> aws_db_instance.<logical_name>.db_name
                □ database_user -> aws_db_instance.<logical_name>.username
            § variables.tf
        ○ /s3
            § main.tf
                □ aws_s3_bucket (bucket used for uploading the application)
                □ aws_s3_bucket_versioning (enabling S3 versioning on the bucket)
            § outputs.tf
                □ s3_bucket_arn -> aws_s3_bucket.<logical_name>.arn
                □ s3_bucket_id -> aws_s3_bucket.<logical_name>.id
                □ bucket_resource > aws_s3_bucket.<logical_name> (resource used by a null provider to create a depends_on relation with the bucket for uploading files to it post-creation of the bucket)
            § variables.tf
        ○ /sg
            § main.tf
                □ aws_security_group (security group for the LB)
                □ aws_vpc_security_group_ingress_rule (ingress rule for http attached to the LB SG)
                □ aws_vpc_security_group_ingress_rule (ingress rule for https attached to the LB SG)
                □ aws_vpc_security_group_egress_rule (egress rule attached to LB SG)
                □ aws_security_group (security group for the EC2 instances)
                □ aws_vpc_security_group_ingress_rule (ingress rule for http attached to the EC2 instances SG, references the LB SG)
                □ aws_vpc_security_group_egress_rule (egress rule attached to EC2 instances SG)
                □ aws_security_group (security group for the RDS database)
                □ aws_vpc_security_group_ingress_rule (ingress rule for mysql port attached to the RDS database, references the EC2 instances SG)
                □ aws_vpc_security_group_egress_rule (egress rule attached to the EC2 instances SG)
            § outputs.tf
                □ alb_sg_id -> aws_security_group.<logical_name>.id
                □ ec2_sg_id -> aws_security_group.<logical_name>.id
                □ data_sg_id -> aws_security_group.<logical_name>.id
            § variables.tf
        ○ /tg
            § main.tf
                □ aws_lb_target_group (target group used by the load balancer)
            § outputs.tf
                □ target_group_arn -> aws_lb_target_group.<logical_name>.arn
                □ target_group_name -> aws_lb_target_group.<logical_name>.name
            § variables.tf
        ○ vpc
            § main.tf
                □ aws_vpc
                □ aws_subnet (public subnet, using for_each as there are multiple subnets each in different AZs)
                □ aws_route_table (route table for the public subnet, routes 0.0.0.0/0 through the aws_internet_gateway)
                □ aws_route_table_association (association for the public route table to each public subnet, using for_each as there are multiple subnets)
                □ aws_subnet (private subnet, using for_each as there are multiple subnets in different AZs)
                □ aws_route_table (route table for the private subnet, routes 0.0.0.0/0 through the aws_nat_gateway)
                □ aws_route_table_association (association for the private route table to each private subnet, using for_each as there are multiple subnets)
                □ aws_internet_gateway (internet gateway resource to access the outside world)
                □ aws_eip (eip used by the nat gateway, depends on aws_internet_gateway)
                □ aws_nat_gateway (nat gateway used by the instances in the private subnet to access outside world)
            § outputs.tf
                □ vpc_arn -> aws_vpc.<logical_name>.arn
                □ vpc_id -> aws_vpc.<logical_name>.id
                □ public_subnet_ids -> for k, s in aws_subnet.public : k => s.id
                □ private_subnet_ids -> for k, s in aws_subnet.private : k => s.id
            § variables.tf
    - templates
        ○ db.php.tpl -> template file for application connection to the database
        ○ userdata.sh.tpl -> template file for the userdata script running on the EC2 instances
    - main.tf
        ○ calling all the modules
        ○ data resource for grabbing an already existing aws_key_pair
        ○ data resource for grabbing the latest amazon linux 2023 aws_ami
        ○ locals block defining a dictionary which contains key/value pairs for database connection of the EC2 instances. this leverages the db.php.tpl template file from the /templates folder
        ○ local_file resource for creating the db.php file locally using the db.php.tpl template file, pre-upload to S3
        ○ null_resource for creating a local-exec provisioner to run an "aws s3 sync" command to upload files from local folder to S3 bucket, this upload depends on the creation of the S3 bucket and the creation of the local db.php file from the db.php.tpl template file
    - outputs.tf
    - terraform.tf
    - variables.tf
