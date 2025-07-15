include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/ecs"
}

dependency "vpc" {
  config_path = "../vpc"
}

dependency "load_balancer" {
  config_path = "../load-balancer"
}

dependency "security_group" {
  config_path = "../security-group"
}

dependency "ecr" {
  config_path = "../ecr"
}

inputs = {
  cluster_name = "helloworld-prod"
  task_family  = "helloworld-prod-task"
  
  # タスク設定（本番環境ではより多くのリソース）
  task_cpu    = "512"
  task_memory = "1024"
  
  # コンテナ設定
  container_name  = "helloworld"
  container_image = "${dependency.ecr.outputs.repository_url}:latest"
  container_port  = 8080
  
  # サービス設定
  service_name     = "helloworld-prod-service"
  desired_count    = 2  # 本番環境では冗長性のため2つのタスク
  assign_public_ip = false  # 本番環境ではプライベートサブネットを使用
  
  # ネットワーク設定
  vpc_id                = dependency.vpc.outputs.vpc_id
  subnet_ids            = dependency.vpc.outputs.private_subnet_ids
  allowed_cidr_blocks   = [dependency.vpc.outputs.vpc_cidr_block]
  
  # ALB設定
  target_group_arn      = dependency.load_balancer.outputs.target_group_arns[0]
  alb_security_group_id = dependency.security_group.outputs.security_group_id
  
  # 環境変数
  environment_variables = [
    {
      name  = "PORT"
      value = "8080"
    },
    {
      name  = "ENV"
      value = "production"
    }
  ]
  
  # ヘルスチェック
  health_check_command = "curl -f http://localhost:8080/health || exit 1"
  
  # ログ設定（本番環境では長期保存）
  log_retention_days = 30
  
  tags = {
    Environment = "prod"
    Application = "helloworld"
  }
}
