########################################################################################
# Lambda
########################################################################################

resource "aws_lambda_function" "command" {
  function_name    = "${var.prefix}-command"
  description      = "intercepts discord command requests"
  role             = aws_iam_role.command.arn
  handler          = "app.handler"
  runtime          = "nodejs14.x"
  filename         = "${path.root}/input/command-lambda.zip"
  source_code_hash = filebase64sha256("${path.root}/input/command-lambda.sha256sum")
  environment {
    variables = {
      discord_api_key = aws_secretsmanager_secret_version.discord_api_key.arn
    }
  }
  tags = var.tags
  # must be able to respond to command api calls within 3 seconds
  # cold start up can take 1 second
  timeout = 3
}

########################################################################################
# IAM
########################################################################################

resource "aws_iam_role" "command" {
  name        = "${var.prefix}-command"
  description = "Execution role for discord command function"
  path        = var.iam_path
  assume_role_policy = jsonencode({
    Version = var.iam_policy_version
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  force_detach_policies = true
  tags                  = var.tags
}

resource "aws_iam_role_policy_attachment" "command-read-secrets" {
  role       = aws_iam_role.command.name
  policy_arn = aws_iam_policy.read-secret.arn
}
