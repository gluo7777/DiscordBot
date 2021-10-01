terraform {
  required_version = ">=1.0.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=3"
    }
  }
  backend "remote" {
    organization = "williamluo7777"
    workspaces {
      name = "discord-bot"
    }
  }
}

variable "access_key" {}
variable "secret_key" {}
variable "role_arn" {}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = "us-east-1"
  profile    = var.profile
  assume_role {
    role_arn = var.role_arn
  }
}