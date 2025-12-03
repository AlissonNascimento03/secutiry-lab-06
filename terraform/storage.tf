# ❌ VULNERABILIDADES EM STORAGE

# S3 bucket público sem encryption
resource "aws_s3_bucket" "data" {
  bucket = "security-lab-06-data-bucket"
  
  # ❌ Deprecated mas ainda usado
  acl = "public-read"  # Público!
  
  tags = {
    Name        = "data-bucket"
    Environment = "production"
  }
}

# ❌ VULNERABILIDADE: Sem block public access
resource "aws_s3_bucket_public_access_block" "data" {
  bucket = aws_s3_bucket.data.id
  
  block_public_acls       = false  # Deveria ser true!
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# ❌ VULNERABILIDADE: Sem encryption
# Falta aws_s3_bucket_server_side_encryption_configuration

# ❌ VULNERABILIDADE: Sem versioning
# Falta aws_s3_bucket_versioning

# ❌ VULNERABILIDADE: Logging desabilitado
# Falta aws_s3_bucket_logging

# RDS sem encryption e backup
resource "aws_db_instance" "main" {
  identifier = "security-lab-06-db"
  
  engine         = "postgres"
  engine_version = "13.7"
  instance_class = "db.t3.micro"
  
  allocated_storage = 20
  storage_type      = "gp2"
  
  # ❌ VULNERABILIDADE: Sem encryption
  storage_encrypted = false
  
  # ❌ VULNERABILIDADE: Banco público
  publicly_accessible = true
  
  # ❌ VULNERABILIDADE: Credenciais hardcoded
  username = "admin"
  password = "Password123!"  # Nunca fazer isso!
  
  # ❌ VULNERABILIDADE: Backup desabilitado
  backup_retention_period = 0
  
  # ❌ VULNERABILIDADE: Deletion protection off
  deletion_protection = false
  
  # ❌ VULNERABILIDADE: Logs desabilitados
  enabled_cloudwatch_logs_exports = []
  
  skip_final_snapshot = true
  
  tags = {
    Name = "main-database"
  }
}
