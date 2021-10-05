########################################################################################
# Interaction
########################################################################################

resource "aws_lambda_function" "interaction" {
  function_name    = "${var.prefix}-${local.lambdas["interaction"].name}"
  description      = "${var.prefix}-${local.lambdas["interaction"].description}"
  role             = aws_iam_role.lambda["interaction"].arn
  handler          = "app.handler"
  runtime          = "nodejs14.x"
  s3_bucket        = aws_s3_bucket_object.lambda["interaction"].bucket
  s3_key           = aws_s3_bucket_object.lambda["interaction"].key
  source_code_hash = data.archive_file.lambda["interaction"].output_base64sha256
  environment {
    variables = {
      command_function_arn = aws_lambda_function.command.arn
      discord_public_key   = var.discord_public_key
    }
  }
  tags = var.tags
  # must be able to respond to interaction api calls within 3 seconds
  # cold start up can take 1 second
  timeout = 3
}

resource "aws_iam_role_policy_attachment" "interaction-invoke-command" {
  role       = aws_iam_role.lambda["interaction"].name
  policy_arn = aws_iam_policy.invoke-command.arn
}

########################################################################################
# Command
########################################################################################

resource "aws_lambda_function" "command" {
  function_name    = "${var.prefix}-${local.lambdas["command"].name}"
  description      = "${var.prefix}-${local.lambdas["command"].description}"
  role             = aws_iam_role.lambda["command"].arn
  handler          = "app.handler"
  runtime          = "nodejs14.x"
  s3_bucket        = aws_s3_bucket_object.lambda["command"].bucket
  s3_key           = aws_s3_bucket_object.lambda["command"].key
  source_code_hash = data.archive_file.lambda["command"].output_base64sha256
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
# Common Resources
########################################################################################

data "archive_file" "lambda" {
  for_each    = local.lambdas
  type        = "zip"
  source_dir  = "${local.input}/${each.value.name}"
  output_path = "${local.output}/${each.value.name}.zip"
  excludes    = [".gitignore", "package.json", "package-lock.json"]
}

resource "aws_s3_bucket_object" "lambda" {
  for_each    = local.lambdas
  bucket      = aws_s3_bucket.code_bucket.id
  source      = data.archive_file.lambda[each.key].output_path
  key         = "${each.value.name}.zip"
  source_hash = data.archive_file.lambda[each.key].output_md5
}

resource "aws_iam_role" "lambda" {
  for_each    = local.lambdas
  name        = "${var.prefix}-${each.value.name}"
  description = "Execution role for ${each.value.name}"
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

resource "aws_iam_role_policy_attachment" "interaction-AWSLambdaBasicExecutionRole" {
  for_each   = local.lambdas
  role       = aws_iam_role.lambda[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda-read-secrets" {
  for_each   = local.lambdas
  role       = aws_iam_role.lambda[each.key].name
  policy_arn = aws_iam_policy.read-secret.arn
}

