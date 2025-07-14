include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/iam"
}

inputs = {
  create_role                = true
  role_name                  = "helloworld-prod-ecs-task-role"
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

  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]

  create_instance_profile    = true
  instance_profile_name      = "helloworld-prod-instance-profile"

  tags = {
    Environment = "prod"
    Application = "helloworld"
  }
}
