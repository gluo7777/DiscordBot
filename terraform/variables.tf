########################################################################################
# Local
########################################################################################

locals {
  input   = "${path.root}/input"
  output  = "${path.root}/output"
  zone    = data.aws_route53_zone.domain.id
  account = data.aws_caller_identity.current.account_id
  region  = data.aws_region.current.name
  lambdas = {
    interaction = {
      name        = "interaction-lambda"
      description = "responds to ping and command requests from discord"
    }
    command = {
      name        = "command-lambda"
      description = "asynchronously invoked to follow up on command requests"
    }
  }
}

########################################################################################
# Input
########################################################################################
variable "profile" {
  description = "AWS CLI profile"
  default     = "default"
}

variable "prefix" {
  default = "discord"
}

variable "subdomain" {
  default = "discord"
}

variable "iam_policy_version" {
  default = "2012-10-17"
}

variable "iam_path" {
  default = "/discord/"
}

variable "discord_api_key" {
  type      = string
  sensitive = true
}

variable "discord_public_key" {
  type = string
}

variable "discord_bot_token" {
  type = string
  sensitive = true
}

variable "tags" {
  type = map(string)
  default = {
    environment = "prod"
    app         = "DiscordBot"
    author      = "William Ma"
    deployment  = "Terraform"
  }
}

########################################################################################
# Datasources
########################################################################################

data "aws_caller_identity" "current" {

}

data "aws_region" "current" {

}

data "aws_route53_zone" "domain" {
  name         = "williamluo.com"
  private_zone = false
}
