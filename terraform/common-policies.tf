resource "aws_iam_policy" "read-secret" {
  name = "${var.prefix}-read-secrets"
  path = var.prefix
  policy = jsonencode({
    Version = var.iam_policy_version
    Statement = [
      {
        Effect   = "Allow"
        Resource = "*"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
      }
    ]
  })
  tags = var.tags
  lifecycle {
    create_before_destroy = false
  }
}
