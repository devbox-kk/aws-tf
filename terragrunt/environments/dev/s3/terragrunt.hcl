# 開発環境用S3バケット設定
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/s3"
}

inputs = {
  bucket_name = "my-dev-bucket-20250702"
  
  # Static website hosting configuration
  enable_website_hosting = true
  block_public_access    = false

  tags = {
    Environment = "dev"
    Project     = "aws-tf"
    ManagedBy   = "terragrunt"
  }
}

