terraform {
  # backend "s3" {}
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "main" {
  count = var.create_log_group ? 1 : 0

  name              = var.log_group_name
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = var.log_group_name
  })
}

# CloudWatch Metric Alarm
resource "aws_cloudwatch_metric_alarm" "main" {
  count = length(var.metric_alarms)

  alarm_name          = var.metric_alarms[count.index].alarm_name
  comparison_operator = var.metric_alarms[count.index].comparison_operator
  evaluation_periods  = var.metric_alarms[count.index].evaluation_periods
  metric_name         = var.metric_alarms[count.index].metric_name
  namespace           = var.metric_alarms[count.index].namespace
  period              = var.metric_alarms[count.index].period
  statistic           = var.metric_alarms[count.index].statistic
  threshold           = var.metric_alarms[count.index].threshold
  alarm_description   = var.metric_alarms[count.index].alarm_description
  alarm_actions       = var.metric_alarms[count.index].alarm_actions

  dimensions = var.metric_alarms[count.index].dimensions

  tags = merge(var.tags, {
    Name = var.metric_alarms[count.index].alarm_name
  })
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  count = var.create_dashboard ? 1 : 0

  dashboard_name = var.dashboard_name
  dashboard_body = var.dashboard_body
}

# CloudWatch Event Rule
resource "aws_cloudwatch_event_rule" "main" {
  count = length(var.event_rules)

  name                = var.event_rules[count.index].name
  description         = var.event_rules[count.index].description
  event_pattern       = var.event_rules[count.index].event_pattern
  schedule_expression = var.event_rules[count.index].schedule_expression

  tags = merge(var.tags, {
    Name = var.event_rules[count.index].name
  })
}

# CloudWatch Event Target
resource "aws_cloudwatch_event_target" "main" {
  count = length(var.event_targets)

  rule      = aws_cloudwatch_event_rule.main[var.event_targets[count.index].rule_index].name
  target_id = var.event_targets[count.index].target_id
  arn       = var.event_targets[count.index].arn
}
