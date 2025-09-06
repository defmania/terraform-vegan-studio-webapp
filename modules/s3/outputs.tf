output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.s3_bucket.arn
}

output "s3_bucket_id" {
  description = "S3 bucket ID"
  value       = aws_s3_bucket.s3_bucket.id
}

output "bucket_resource" {
  description = "Using this to set the bucket resource to be used by the null provider"
  value       = aws_s3_bucket.s3_bucket
}
