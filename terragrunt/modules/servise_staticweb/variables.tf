variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "s3_bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  type        = string
}

variable "price_class" {
  description = "Price class for CloudFront distribution"
  type        = string
  default     = "PriceClass_All"
}

variable "callback_urls" {
  description = "List of callback URLs for Cognito User Pool Client"
  type        = list(string)
}

variable "logout_urls" {
  description = "List of logout URLs for Cognito User Pool Client"
  type        = list(string)
}

variable "lambda_role_arn" {
  description = "ARN of the Lambda@Edge role"
  type        = string
}