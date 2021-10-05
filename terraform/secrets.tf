resource "aws_secretsmanager_secret" "discord_api_key" {
  name = "${var.prefix}-api-key"
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "discord_api_key" {
  secret_id = aws_secretsmanager_secret.discord_api_key.id
  secret_string = jsonencode({
    key = var.discord_api_key
  })
}

resource "aws_secretsmanager_secret" "discord_bot_token" {
  name = "${var.prefix}-bot-token"
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "discord_bot_token" {
  secret_id = aws_secretsmanager_secret.discord_bot_token.id
  secret_string = jsonencode({
    key = var.discord_bot_token
  })
}
