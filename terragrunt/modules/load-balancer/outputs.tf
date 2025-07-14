output "load_balancer_arn" {
  description = "ARN of the load balancer"
  value       = var.load_balancer_type == "application" ? aws_lb.main[0].arn : aws_lb.network[0].arn
}

output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = var.load_balancer_type == "application" ? aws_lb.main[0].dns_name : aws_lb.network[0].dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  value       = var.load_balancer_type == "application" ? aws_lb.main[0].zone_id : aws_lb.network[0].zone_id
}

output "target_group_arns" {
  description = "ARNs of the target groups"
  value       = aws_lb_target_group.main[*].arn
}

output "listener_arns" {
  description = "ARNs of the listeners"
  value       = aws_lb_listener.main[*].arn
}
