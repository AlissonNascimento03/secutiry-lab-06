# ❌ VULNERABILIDADES EM IAM

# IAM user com credentials
resource "aws_iam_user" "developer" {
  name = "developer"
  
  tags = {
    Role = "Developer"
  }
}

# ❌ VULNERABILIDADE: Access key programático (evitar)
resource "aws_iam_access_key" "developer" {
  user = aws_iam_user.developer.name
}

# ❌ VULNERABILIDADE: Policy muito permissiva (*:*)
resource "aws_iam_policy" "admin_like" {
  name        = "admin-like-policy"
  description = "Policy with excessive permissions"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "*"  # Todas as ações!
        Resource = "*"  # Todos os recursos!
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "developer_admin" {
  user       = aws_iam_user.developer.name
  policy_arn = aws_iam_policy.admin_like.arn
}

# ❌ VULNERABILIDADE: Role sem condições
resource "aws_iam_role" "lambda_role" {
  name = "lambda-execution-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        # Sem condições de segurança!
      }
    ]
  })
}

# ❌ VULNERABILIDADE: Password policy fraca
resource "aws_iam_account_password_policy" "weak" {
  minimum_password_length        = 6  # Muito curto!
  require_lowercase_characters   = false
  require_numbers                = false
  require_uppercase_characters   = false
  require_symbols                = false
  allow_users_to_change_password = true
  max_password_age               = 0  # Nunca expira!
}
