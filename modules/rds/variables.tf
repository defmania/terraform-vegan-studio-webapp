variable "db_identifier" {}
variable "db_subnet_group_name" {}
variable "db_subnet_group_description" {}
variable "db_subnet_ids" {}
variable "db_engine" {}
variable "db_engine_version" {}
variable "db_instance_class" {}
variable "db_allocated_storage" {}
variable "db_security_group" {}
variable "db_username" {}
variable "db_name" {}
variable "db_password" {
  sensitive = true
}
