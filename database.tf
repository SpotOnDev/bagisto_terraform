resource "random_password" "db_master_pass" {
  length      = 40
  special     = false
  min_special = 5
  # override_special  = "!#$%^&*()-_=+[]{}<>:?"
  keepers = {
    pass_version = 1
  }
}

resource "aws_db_instance" "default" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0.28"
  instance_class         = "db.t3.micro"
  identifier             = "bagisto-db"
  username               = "admin"
  password               = random_password.db_master_pass.result
  parameter_group_name   = "defaultcopymysql8"
  vpc_security_group_ids = [aws_security_group.db-sg.id]
}