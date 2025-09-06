resource "aws_db_subnet_group" "data_subnet_group" {
  name        = var.db_subnet_group_name
  description = var.db_subnet_group_description
  subnet_ids  = var.db_subnet_ids

  tags = {
    Name = var.db_subnet_group_name
  }
}

resource "aws_db_instance" "database_instance" {
  identifier             = var.db_identifier
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  db_subnet_group_name   = aws_db_subnet_group.data_subnet_group.name
  vpc_security_group_ids = [var.db_security_group]
  multi_az               = true
  skip_final_snapshot    = true
  publicly_accessible    = false
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
}
