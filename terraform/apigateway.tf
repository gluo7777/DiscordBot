########################################################################################
# API
########################################################################################

resource "aws_api_gateway_rest_api" "discord" {
  name        = "Discord Interaction API"
  description = "API to handle discord interaction requests"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  tags = var.tags
}

########################################################################################
# Deployment
########################################################################################

resource "aws_api_gateway_deployment" "discord" {
  rest_api_id = local.rest_api_id
  triggers = {
    redeployment = filebase64sha256("${path.module}/apigateway.tf")
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "discord" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.discord.id
  deployment_id = aws_api_gateway_deployment.discord.id
  tags          = var.tags
}

resource "aws_api_gateway_domain_name" "discord" {
  certificate_arn = aws_acm_certificate_validation.discord.certificate_arn
  domain_name     = aws_acm_certificate.discord.domain_name
}

resource "aws_api_gateway_base_path_mapping" "discord" {
  api_id      = aws_api_gateway_rest_api.discord.id
  stage_name  = aws_api_gateway_stage.discord.stage_name
  domain_name = aws_api_gateway_domain_name.discord.domain_name
}

########################################################################################
# Resources
########################################################################################

resource "aws_api_gateway_resource" "interactions" {
  rest_api_id = aws_api_gateway_rest_api.discord.id
  parent_id   = aws_api_gateway_rest_api.discord.root_resource_id
  path_part   = "interactions"
}

########################################################################################
# POST /interactions
########################################################################################

resource "aws_api_gateway_method" "post-interactions" {
  rest_api_id = aws_api_gateway_rest_api.discord.id
  resource_id = aws_api_gateway_resource.interactions.id
  http_method = "POST"
}

resource "aws_api_gateway_integration" "post-interactions" {
  resource_id             = aws_api_gateway_method.post-interactions.id
  rest_api_id             = aws_api_gateway_method.post-interactions.rest_api_id
  type                    = "AWS_PROXY"
  http_method             = "POST"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.interaction.invoke_arn
  timeout_milliseconds    = 29000
}

resource "aws_lambda_permission" "post-interactions" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.interaction.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${local.region}:${local.account}:${aws_api_gateway_rest_api.discord.id}/*/${aws_api_gateway_method.post-interactions.http_method}${aws_api_gateway_resource.interactions.path}"
}
