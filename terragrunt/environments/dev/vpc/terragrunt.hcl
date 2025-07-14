include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/vpc"
}

inputs = {
  vpc_name = "helloworld-dev-vpc"
  vpc_cidr = "10.0.0.0/16"
  
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
  
  enable_nat_gateway = false  # 開発環境ではコスト削減のためNAT Gatewayを無効化
  
  # ALB設定
  enable_alb         = true
  target_group_port  = 8080
  health_check_path  = "/"
  
  tags = {
    Environment = "dev"
    Application = "helloworld"
  }
}
