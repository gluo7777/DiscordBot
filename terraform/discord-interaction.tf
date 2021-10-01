########################################################################################
# Lambda
########################################################################################

resource "aws_lambda_function" "interaction" {
  function_name    = "${var.prefix}-interaction"
  description      = "intercepts discord interaction requests"
  role             = aws_iam_role.interaction.arn
  handler          = "app.handler"
  runtime          = "nodejs14.x"
  filename         = "${path.root}/input/interaction-lambda.zip"
  source_code_hash = filebase64sha256("${path.root}/input/interaction-lambda.sha256sum")
  environment {
    variables = {
      command_function_arn = "TODO"
    }
  }
  tags = var.tags
  # must be able to respond to interaction api calls within 3 seconds
  # cold start up can take 1 second
  timeout = 2
}

########################################################################################
# IAM
########################################################################################

resource "aws_iam_role" "interaction" {
  name        = "${var.prefix}-interaction"
  description = "Execution role for discord interaction function"
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

resource "aws_iam_role_policy_attachment" "interaction-read-secrets" {
  role       = aws_iam_role.interaction.name
  policy_arn = aws_iam_policy.read-secret.arn
}
