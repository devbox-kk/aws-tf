terraform {
  source = "../../../modules/cloudfront"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "s3" {
  config_path = "../s3"
}

inputs = {
  name_prefix                      = "prod-website"
  s3_bucket_name                   = dependency.s3.outputs.bucket_id
  s3_bucket_regional_domain_name   = dependency.s3.outputs.bucket_regional_domain_name
  s3_bucket_arn                    = dependency.s3.outputs.bucket_arn
  price_class                      = "PriceClass_100"
  
  tags = {
    Environment = "prod"
    Project     = "website-hosting"
  }
}
