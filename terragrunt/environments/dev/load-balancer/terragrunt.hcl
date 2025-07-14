include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/load-balancer"
}

dependency "vpc" {
  config_path = "../vpc"
}

dependency "security_group" {
  config_path = "../security-group"
}

inputs = {
  load_balancer_type         = "application"
  load_balancer_name         = "helloworld-dev-alb"
  security_group_ids         = [dependency.security_group.outputs.security_group_id]
  subnet_ids                 = dependency.vpc.outputs.public_subnet_ids
  vpc_id                     = dependency.vpc.outputs.vpc_id
  enable_deletion_protection = false

  target_groups = [
    {
      name     = "helloworld-dev-tg"
      port     = 8080
      protocol = "HTTP"
      health_check = {
        enabled             = true
        healthy_threshold   = 2
        interval            = 30
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }
    }
  ]

  listeners = [
    {
      port            = 80
      protocol        = "HTTP"
      ssl_policy      = null
      certificate_arn = null
      default_action = {
        type               = "forward"
        target_group_index = 0
      }
    }
  ]

  tags = {
    Environment = "dev"
    Application = "helloworld"
  }
}
