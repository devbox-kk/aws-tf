terraform {
  source = "../../../modules/servise_staticweb"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "source" {
  config_path = "../source"

  mock_outputs = {
    bucket_id                   = "dev-website-bucket"
    bucket_regional_domain_name = "dev-website-bucket.s3.us-east-1.amazonaws.com"
    bucket_arn                  = "arn:aws:s3:::dev-website-bucket"
    bucket_regional_domain_name = "dev-website-bucket.s3.us-east-1.amazonaws.com"
  }
}

dependency "iam" {
  config_path = "../iam"

  mock_outputs = {
    lambda_role_arn = "arn:aws:iam::123456789012:role/dev-lambda-role"
  }
}

inputs = {
  s3_bucket_name                   = dependency.source.outputs.bucket_id
  s3_bucket_regional_domain_name   = dependency.source.outputs.bucket_regional_domain_name
  s3_bucket_arn                    = dependency.source.outputs.bucket_arn
  price_class                      = "PriceClass_100"
  callback_urls                    = ["https://${dependency.source.outputs.bucket_regional_domain_name}/callback"]
  logout_urls                      = ["https://${dependency.source.outputs.bucket_regional_domain_name}/logout"]
  lambda_role_arn                  = dependency.iam.outputs.lambda_role_arn
}
