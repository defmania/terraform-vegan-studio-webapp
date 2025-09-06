output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.vs_asg.name
}

output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.vs_lt.id
}
