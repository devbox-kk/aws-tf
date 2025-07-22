include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/source"
}

inputs = {

  force_delete    = true
  
  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Delete untagged images older than 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  bucket_name = "my-dev-bucket-20250702"
  
  # Static website hosting configuration
  enable_website_hosting = true
  block_public_access    = false
}
