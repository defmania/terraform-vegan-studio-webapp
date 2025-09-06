variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket"
  default     = "vs-bucket-defmania"
}

variable "db_password" {
  type        = string
  description = "Database password"
}

variable "key_pair_name" {
  type        = string
  description = "EC ssh key"
  default     = "def-yoga2"
}

variable "app_fqdn" {
  type = string
  description = "FQDN of the load balancer"
}

variable "my_hosted_zone_name" {
  type = string
  description = "Name of the Route 53 hosted zone"
}
