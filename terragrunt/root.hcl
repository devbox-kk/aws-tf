# Terragruntルート設定
# この設定は全環境で共有される

# AWS provider configuration
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}
EOF
}

# リモートステート設定
remote_state {
  backend = "s3"
  config = {
    bucket  = "terraform-state-${get_aws_account_id()}"
    key     = "${path_relative_to_include()}/terraform.tfstate"
    region  = "ap-northeast-1"
    encrypt = true

    dynamodb_table = "terraform-state-lock"
  }
}

# 共通inputs
inputs = {
  aws_region = "ap-northeast-1"
}
