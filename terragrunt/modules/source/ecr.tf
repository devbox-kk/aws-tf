terraform {
  # backend "s3" {}
}

resource "aws_ecr_repository" "main" {
  name                 = var.name_prefix
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = var.tags
}

resource "aws_ecr_lifecycle_policy" "main" {
  count      = var.lifecycle_policy != null ? 1 : 0
  repository = aws_ecr_repository.main.name

  policy = var.lifecycle_policy
}

# ECR repository policy for cross-account access (optional)
resource "aws_ecr_repository_policy" "main" {
  count      = var.repository_policy != null ? 1 : 0
  repository = aws_ecr_repository.main.name
  policy     = var.repository_policy
}
