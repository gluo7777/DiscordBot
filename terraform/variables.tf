variable "profile" {
  description = "AWS CLI profile"
  default     = "default"
}

variable "prefix" {
  default = "discord"
}

variable "iam_policy_version" {
  default = "2021-10-17"
}

variable "iam_path" {
  default = "/DiscordBot/"
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