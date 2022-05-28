resource "aws_secretsmanager_secret" "db-pass" {
  name = "prod/bagisto"
}

resource "aws_secretsmanager_secret_version" "db-pass-val" {
  secret_id     = aws_secretsmanager_secret.db-pass.id
  secret_string = random_password.db_master_pass.result
}