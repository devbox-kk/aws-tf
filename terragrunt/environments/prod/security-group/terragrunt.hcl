include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/security-group"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  security_group_name        = "helloworld-prod-sg"
  security_group_description = "Security group for helloworld production environment"
  vpc_id                     = dependency.vpc.outputs.vpc_id

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  tags = {
    Environment = "prod"
    Application = "helloworld"
  }
}
