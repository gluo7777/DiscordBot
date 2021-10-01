terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=3"
    }
  }
  backend "s3" {
    bucket = "gluo7777-terraform-state"
    key    = "DiscordBot/v1"
    region = "us-east-1"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = var.profile
}