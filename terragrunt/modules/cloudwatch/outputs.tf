output "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = var.create_log_group ? aws_cloudwatch_log_group.main[0].arn : null
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = var.create_log_group ? aws_cloudwatch_log_group.main[0].name : null
}

output "metric_alarm_arns" {
  description = "ARNs of the CloudWatch metric alarms"
  value       = aws_cloudwatch_metric_alarm.main[*].arn
}

output "dashboard_arn" {
  description = "ARN of the CloudWatch dashboard"
  value       = var.create_dashboard ? aws_cloudwatch_dashboard.main[0].dashboard_arn : null
}

output "event_rule_arns" {
  description = "ARNs of the CloudWatch event rules"
  value       = aws_cloudwatch_event_rule.main[*].arn
}
