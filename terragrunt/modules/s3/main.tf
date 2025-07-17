terraform {
  # backend "s3" {}
}

resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id
  
  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

# Static website hosting configuration
resource "aws_s3_bucket_website_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Upload static website files
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.main.id
  key          = "index.html"
  source       = "${path.module}/../../../../../../../sample-website/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/../../../../../../../sample-website/index.html")
}

resource "aws_s3_object" "styles_css" {
  bucket       = aws_s3_bucket.main.id
  key          = "styles.css"
  source       = "${path.module}/../../../../../../../sample-website/styles.css"
  content_type = "text/css"
  etag         = filemd5("${path.module}/../../../../../../../sample-website/styles.css")
}

resource "aws_s3_object" "script_js" {
  bucket       = aws_s3_bucket.main.id
  key          = "script.js"
  source       = "${path.module}/../../../../../../../sample-website/script.js"
  content_type = "application/javascript"
  etag         = filemd5("${path.module}/../../../../../../../sample-website/script.js")
}

resource "aws_s3_object" "error_html" {
  bucket       = aws_s3_bucket.main.id
  key          = "error.html"
  source       = "${path.module}/../../../../../../../sample-website/error.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/../../../../../../../sample-website/error.html")
}

# Bucket policy will be managed by CloudFront module

