include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/cloudwatch"
}

dependency "load_balancer" {
  config_path = "../load-balancer"
  mock_outputs = {
    load_balancer_arn = "arn:aws:elasticloadbalancing:ap-northeast-1:123456789012:loadbalancer/app/mock-alb/123456789012345678"
  }
}

inputs = {
  create_log_group    = true
  log_group_name      = "/aws/ecs/helloworld-dev"
  log_retention_days  = 7

  metric_alarms = [
    {
      alarm_name          = "helloworld-dev-high-cpu"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name         = "CPUUtilization"
      namespace           = "AWS/ECS"
      period              = 300
      statistic           = "Average"
      threshold           = 80
      alarm_description   = "High CPU utilization in development environment"
      alarm_actions       = []
      dimensions = {
        ServiceName = "helloworld-dev-service"
      }
    }
  ]

  create_dashboard = true
  dashboard_name   = "helloworld-dev-dashboard"
  dashboard_body   = jsonencode({
    widgets = [
      {
        type   = "metric"
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", "helloworld-dev-service"]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "ECS CPU Utilization"
        }
      }
    ]
  })

  tags = {
    Environment = "dev"
    Application = "helloworld"
  }
}
