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
  log_group_name      = "/aws/ecs/helloworld-prod"
  log_retention_days  = 30

  metric_alarms = [
    {
      alarm_name          = "helloworld-prod-high-cpu"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name         = "CPUUtilization"
      namespace           = "AWS/ECS"
      period              = 300
      statistic           = "Average"
      threshold           = 70
      alarm_description   = "High CPU utilization in production environment"
      alarm_actions       = []
      dimensions = {
        ServiceName = "helloworld-prod-service"
      }
    },
    {
      alarm_name          = "helloworld-prod-high-memory"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name         = "MemoryUtilization"
      namespace           = "AWS/ECS"
      period              = 300
      statistic           = "Average"
      threshold           = 80
      alarm_description   = "High memory utilization in production environment"
      alarm_actions       = []
      dimensions = {
        ServiceName = "helloworld-prod-service"
      }
    }
  ]

  create_dashboard = true
  dashboard_name   = "helloworld-prod-dashboard"
  dashboard_body   = jsonencode({
    widgets = [
      {
        type   = "metric"
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", "helloworld-prod-service"],
            [".", "MemoryUtilization", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "ECS Resource Utilization"
        }
      }
    ]
  })

  tags = {
    Environment = "prod"
    Application = "helloworld"
  }
}
