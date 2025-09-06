output "database_endpoint" {
  value = module.rds.database_endpoint
}

output "private_subnet_ids" {
  value = module.networking.private_subnet_ids
}

output "public_subnet_ids" {
  value = module.networking.public_subnet_ids
}

output "s3_bucket_arn" {
  value = module.s3.s3_bucket_arn
}

output "database_name" {
  value = module.rds.database_name
}
