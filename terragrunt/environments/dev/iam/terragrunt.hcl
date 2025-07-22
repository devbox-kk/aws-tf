include {
  path = find_in_parent_folders("terragrunt.hcl")
}

terraform {
  source = "../../../modules/iam"
}

inputs = {
  create_role                = true
  assume_role_policy         = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"

}
