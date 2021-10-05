resource "aws_iam_policy" "read-secret" {
  name = "${var.prefix}-read-secrets"
  path = var.iam_path
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

resource "aws_iam_policy" "invoke-command" {
  name = "${var.prefix}-invoke-command"
  path = var.iam_path
  policy = jsonencode({
    Version = var.iam_policy_version
    Statement = [
      {
        Effect   = "Allow"
        Resource = aws_lambda_function.command.arn
        Action = [
          "lambda:InvokeFunction"
        ]
      }
    ]
  })
  tags = var.tags
  lifecycle {
    create_before_destroy = false
  }
}