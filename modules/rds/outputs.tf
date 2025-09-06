output "database_endpoint" {
  description = "Endpoint of the database"
  value       = aws_db_instance.database_instance.endpoint
}

output "database_name" {
  description = "Name of the database"
  value       = aws_db_instance.database_instance.db_name
}

output "db_user" {
  description = "Name of the database user"
  value       = aws_db_instance.database_instance.username
}
