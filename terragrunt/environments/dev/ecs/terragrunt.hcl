include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/ecs"
}

dependency "vpc" {
  config_path = "../vpc"
  
  mock_outputs = {
    vpc_id                = "vpc-mock"
    public_subnet_ids     = ["subnet-mock-1", "subnet-mock-2"]
    target_group_arn      = "arn:aws:elasticloadbalancing:ap-northeast-1:123456789012:targetgroup/mock/123456789012345"
    alb_security_group_id = "sg-mock"
  }
}

dependency "ecr" {
  config_path = "../ecr"
  
  mock_outputs = {
    repository_url = "123456789012.dkr.ecr.ap-northeast-1.amazonaws.com/helloworld-dev"
  }
}

inputs = {
  cluster_name = "helloworld-dev"
  task_family  = "helloworld-dev-task"
  
  # タスク設定
  task_cpu    = "256"
  task_memory = "512"
  
  # コンテナ設定
  container_name  = "helloworld"
  container_image = "${dependency.ecr.outputs.repository_url}:latest"
  container_port  = 8080
  
  # サービス設定
  service_name     = "helloworld-dev-service"
  desired_count    = 1
  assign_public_ip = true  # パブリックサブネットの場合はtrue、プライベートサブネット+NATの場合はfalse
  
  # ネットワーク設定
  vpc_id                = dependency.vpc.outputs.vpc_id
  subnet_ids            = dependency.vpc.outputs.public_subnet_ids  # ALB使用時はプライベートサブネットに変更も可能
  allowed_cidr_blocks   = ["0.0.0.0/0"]
  
  # ALB設定
  target_group_arn      = dependency.vpc.outputs.target_group_arn
  alb_security_group_id = dependency.vpc.outputs.alb_security_group_id
  
  # 環境変数
  environment_variables = [
    {
      name  = "PORT"
      value = "8080"
    },
    {
      name  = "ENV"
      value = "development"
    }
  ]
  
  # ヘルスチェック
  health_check_command = "curl -f http://localhost:8080/health || exit 1"
  
  # ログ設定
  log_retention_days = 7
  
  tags = {
    Environment = "dev"
    Application = "helloworld"
  }
}
