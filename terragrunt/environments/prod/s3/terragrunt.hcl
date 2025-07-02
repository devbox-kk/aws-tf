# 本番環境用S3バケット設定
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/s3"
}

inputs = {
  bucket_name = "my-prod-bucket-20250702"

  tags = {
    Environment = "prod"
    Project     = "aws-tf"
    ManagedBy   = "terragrunt"
  }

  versioning_enabled  = true
  block_public_access = true
}
