include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/servise_dynamicweb"
}

dependency "network" {
  config_path = "../network"
  
  mock_outputs = {
    vpc_id                = "vpc-mock"
    public_subnet_ids     = ["subnet-mock-1", "subnet-mock-2"]
    target_group_arns = ["arn:aws:elasticloadbalancing:ap-northeast-1:123456789012:targetgroup/mock/123456789012345"]
    security_group_id = "sg-mock" 
  }
}

dependency "source" {
  config_path = "../source"
  
  mock_outputs = {
    repository_url = "123456789012.dkr.ecr.ap-northeast-1.amazonaws.com/helloworld-dev"
  }
}

dependency "iam" {
  config_path = "../iam"
  
  mock_outputs = {
    task_role_arn = "arn:aws:iam::123456789012:role/helloworld-dev-task-role"
    execution_role_arn = "arn:aws:iam::123456789012:role/helloworld-dev-execution-role"
  }
}

inputs = {
  
  # タスク設定
  task_cpu    = "256"
  task_memory = "512"
  
  # コンテナ設定
  container_image = "${dependency.source.outputs.repository_url}:latest"
  container_port  = 8080

  # ロール設定
  execution_role_arn = dependency.iam.outputs.execution_role_arn
  task_role_arn      = dependency.iam.outputs.task_role_arn
  
  # サービス設定
  desired_count    = 1
  assign_public_ip = true  # パブリックサブネットの場合はtrue、プライベートサブネット+NATの場合はfalse
  
  # ネットワーク設定
  vpc_id                = dependency.network.outputs.vpc_id
  subnet_ids            = dependency.network.outputs.public_subnet_ids  # ALB使用時はプライベートサブネットに変更も可能
  allowed_cidr_blocks   = ["0.0.0.0/0"]
  
  # ALB設定
  target_group_arn      = dependency.network.outputs.target_group_arn
  alb_security_group_id = dependency.network.outputs.security_group_id

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
}
