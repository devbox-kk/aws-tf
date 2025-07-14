include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/vpc"
}

inputs = {
  vpc_name = "helloworld-prod-vpc"
  vpc_cidr = "10.1.0.0/16"
  
  public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnet_cidrs = ["10.1.10.0/24", "10.1.20.0/24"]
  
  enable_nat_gateway = true  # 本番環境ではセキュリティのためNAT Gatewayを有効化
  
  # ALB設定
  enable_alb         = true
  target_group_port  = 8080
  health_check_path  = "/"
  
  tags = {
    Environment = "prod"
    Application = "helloworld"
  }
}
