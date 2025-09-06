output "certificate_arn" {
  description = "ARN of the created certificate"
  value       = aws_acm_certificate.vs_cert.arn
}
