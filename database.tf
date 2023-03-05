resource "aws_db_subnet_group" "wp_database_subnets" {
  name       = "wp_database_subnets"
  subnet_ids = [aws_subnet.database_a.id, aws_subnet.database_b.id, aws_subnet.database_c.id]
}

resource "aws_db_instance" "wp_db" {
  allocated_storage       = 10
  db_name                 = var.db_name
  engine                  = "mysql"
  engine_version          = var.db_version
  instance_class          = var.db_cpu_type
  username                = var.db_username
  password                = var.db_password
  publicly_accessible     = false
  db_subnet_group_name    = aws_db_subnet_group.wp_database_subnets.id
  vpc_security_group_ids  = [aws_security_group.wp_database_sg.id]
  multi_az                = true
  storage_encrypted       = true
  backup_retention_period = 7
  skip_final_snapshot     = true
}