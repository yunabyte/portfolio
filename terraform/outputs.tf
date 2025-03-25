output "rds_endpoint" {
  description = "RDS Endpoint"
  value       = aws_db_instance.comments_db.endpoint
}

output "rds_port" {
  description = "RDS Port"
  value       = aws_db_instance.comments_db.port
}

output "rds_username" {
  description = "RDS Username"
  value       = var.db_username
}