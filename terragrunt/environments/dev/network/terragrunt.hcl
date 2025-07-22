include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/network"
}

inputs = {
  enable_deletion_protection = false

  vpc_cidr = "10.0.0.0/16"
  
  target_groups = {
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

  listeners = {
    port            = 80
    protocol        = "HTTP"
    ssl_policy      = null
    certificate_arn = null
    default_action = {
      type               = "forward"
      target_group_index = 0
    }
  }

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

  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
  
  enable_nat_gateway = false  # 開発環境ではコスト削減のためNAT Gatewayを無効化
  
  # ALB設定
  enable_alb         = true
  target_group_port  = 8080
  health_check_path  = "/"

}
