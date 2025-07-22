terraform {
  # backend "s3" {}
}

# Lambda@Edge function for Cognito authentication
# リージョンをバージニア州に設定
provider "aws" {
  alias = "virginia"
  region = "us-east-1"
}
resource "aws_lambda_function" "cognito_auth" {
  provider         = aws.virginia
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.name_prefix}-cognito-auth"
  role            = var.lambda_role_arn
  handler         = "index.handler"
  runtime         = "nodejs18.x"
  publish         = true
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  tags = var.tags
}

# Create Lambda function code
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "/tmp/lambda_auth.zip"
  
  source {
    content = templatefile("${path.module}/src/lambda_auth.js", {
      user_pool_id     = aws_cognito_user_pool.main.id
      client_id        = aws_cognito_user_pool_client.main.id
      cognito_domain   = aws_cognito_user_pool_domain.main.domain
    })
    filename = "index.js"
  }
}

