output "vpc_arn" {
  description = "ARN of the VS-VPC"
  value       = aws_vpc.vs_vpc.arn
}

output "vpc_id" {
  description = "ID of the VS-VPC"
  value       = aws_vpc.vs_vpc.id
}

output "public_subnet_ids" {
  value = { for k, s in aws_subnet.public : k => s.id }
}

output "private_subnet_ids" {
  value = { for k, s in aws_subnet.private : k => s.id }
}
