output "aws_role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.instance_role.arn
}

output "aws_instance_profile" {
  description = "Instance profile to be attached to the EC2 instances"
  value       = aws_iam_instance_profile.ec2_profile.name
}
